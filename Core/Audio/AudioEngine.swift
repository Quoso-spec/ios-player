import Foundation
import AVFoundation
import MediaPlayer
import Combine

final class AudioEngine: ObservableObject {
    static let shared = AudioEngine()

    @Published private(set) var playbackState: PlaybackState = .stopped
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var currentSong: Song?
    @Published var volume: Float = 1.0 {
        didSet { audioPlayerNode.volume = volume }
    }

    private var engine: AVAudioEngine!
    private var audioPlayerNode: AVAudioPlayerNode!
    private var eqNode: AVAudioUnitEQ!
    private var currentFile: AVAudioFile?
    private var nextFile: AVAudioFile?

    private var displayLink: CADisplayLink?
    private var cancellables = Set<AnyCancellable>()

    private var gaplessPlayer: GaplessPlayer?
    private var crossfadePlayer: CrossfadePlayer?

    var equalizer: Equalizer { Equalizer(node: eqNode) }

    private init() {
        setupEngine()
        setupRemoteCommandCenter()
    }

    private func setupEngine() {
        engine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        eqNode = AVAudioUnitEQ(numberOfBands: 10)

        setupEqualizerBands()

        engine.attach(audioPlayerNode)
        engine.attach(eqNode)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(audioPlayerNode, to: eqNode, format: format)
        engine.connect(eqNode, to: engine.mainMixerNode, format: format)

        engine.prepare()

        gaplessPlayer = GaplessPlayer(audioPlayerNode: audioPlayerNode, engine: engine)
        crossfadePlayer = CrossfadePlayer(
            playerNode: audioPlayerNode,
            eqNode: eqNode,
            engine: engine
        )
    }

    private func setupEqualizerBands() {
        let frequencies: [Float] = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        for (index, freq) in frequencies.enumerated() {
            let band = eqNode.bands[index]
            band.filterType = .parametric
            band.frequency = freq
            band.bandwidth = 1.0
            band.gain = 0.0
            band.bypass = false
        }
    }

    func load(song: Song) {
        stop()
        currentSong = song
        playbackState = .loading

        guard FileManager.default.fileExists(atPath: song.filePath) else {
            playbackState = .error("File not found")
            return
        }

        do {
            let url = URL(fileURLWithPath: song.filePath)
            currentFile = try AVAudioFile(forReading: url)
            duration = Double(currentFile!.length) / currentFile!.processingFormat.sampleRate

            try engine.start()
            scheduleFile()
            startDisplayLink()
            playbackState = .paused
            updateNowPlayingInfo()
        } catch {
            playbackState = .error("Failed to load: \(error.localizedDescription)")
        }
    }

    private func scheduleFile() {
        guard let file = currentFile else { return }
        audioPlayerNode.scheduleFile(file, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.handlePlaybackCompletion()
            }
        }
    }

    private func handlePlaybackCompletion() {
        guard playbackState == .playing || playbackState == .paused else { return }
        gaplessPlayer?.handlePlaybackCompletion(queue: PlaybackQueueManager.shared)
    }

    func play() {
        guard currentFile != nil else { return }
        do {
            if !engine.isRunning {
                try engine.start()
            }
            audioPlayerNode.play()
            playbackState = .playing
            updateNowPlayingInfo()
        } catch {
            playbackState = .error("Failed to play: \(error.localizedDescription)")
        }
    }

    func pause() {
        audioPlayerNode.pause()
        playbackState = .paused
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        if playbackState.isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        audioPlayerNode.stop()
        stopDisplayLink()
        currentTime = 0
        playbackState = .stopped
        currentSong = nil
        currentFile = nil
    }

    func seek(to time: TimeInterval) {
        guard let file = currentFile else { return }
        let sampleRate = file.processingFormat.sampleRate
        let newSampleTime = AVAudioFramePosition(time * sampleRate)
        let remainingFrames = AVAudioFrameCount(file.length - newSampleTime)

        audioPlayerNode.stop()

        guard remainingFrames > 0 else {
            handlePlaybackCompletion()
            return
        }

        audioPlayerNode.scheduleSegment(
            file,
            startingFrame: newSampleTime,
            frameCount: remainingFrames,
            at: nil
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.handlePlaybackCompletion()
            }
        }

        if playbackState.isPlaying {
            audioPlayerNode.play()
        }

        currentTime = time
        updateNowPlayingInfo()
    }

    func setVolume(_ volume: Float) {
        self.volume = max(0, min(1, volume))
    }

    func fadeOut(duration: TimeInterval = 0.5, completion: @escaping () -> Void) {
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = volume / Float(steps)

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) { [weak self] in
                guard let self = self else { return }
                self.audioPlayerNode.volume = max(0, self.audioPlayerNode.volume - volumeStep)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }

    func fadeIn(to targetVolume: Float, duration: TimeInterval = 0.5) {
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = targetVolume / Float(steps)

        audioPlayerNode.volume = 0

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) { [weak self] in
                guard let self = self else { return }
                self.audioPlayerNode.volume = min(targetVolume, self.audioPlayerNode.volume + volumeStep)
            }
        }
    }

    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(updateTime))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 30, preferred: 30)
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateTime() {
        guard let file = currentFile,
              let nodeTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else {
            return
        }

        let sampleRate = file.processingFormat.sampleRate
        currentTime = Double(playerTime.sampleTime) / sampleRate
    }

    func savePlaybackState() {
        guard let song = currentSong else { return }
        let state: [String: Any] = [
            "songId": song.id,
            "currentTime": currentTime,
            "volume": volume
        ]
        UserDefaults.standard.set(state, forKey: "playbackState")
    }

    func restorePlaybackState(library: MusicLibrary) {
        guard let state = UserDefaults.standard.dictionary(forKey: "playbackState"),
              let songId = state["songId"] as? String,
              let song = library.allSongs.first(where: { $0.id == songId }) else {
            return
        }

        load(song: song)
        if let time = state["currentTime"] as? TimeInterval {
            seek(to: time)
        }
        if let vol = state["volume"] as? Float {
            volume = vol
        }
    }
}

extension AudioEngine {
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            PlaybackQueueManager.shared.next()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            PlaybackQueueManager.shared.previous()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.seek(to: event.positionTime)
            return .success
        }

        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            let newTime = min(self.currentTime + 15, self.duration)
            self.seek(to: newTime)
            return .success
        }

        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            let newTime = max(self.currentTime - 15, 0)
            self.seek(to: newTime)
            return .success
        }
    }

    func updateNowPlayingInfo() {
        guard let song = currentSong else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyAlbumTitle: song.album,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: playbackState.isPlaying ? 1.0 : 0.0,
            MPMediaItemPropertyMediaType: MPMediaType.music.rawValue
        ]

        if let artworkData = song.artworkData,
           let image = UIImage(data: artworkData) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
