import AVFoundation
import Combine
import Foundation

@MainActor
public final class AVQueuePlaybackEngine: ObservableObject, PlaybackEngine {
    @Published public private(set) var state = PlaybackState()
    @Published public private(set) var currentTrack: Track?
    @Published public private(set) var progress: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var queue: [Track] = []

    private let bookmarkResolver: BookmarkResolving
    private let audioSessionCoordinator: AudioSessionCoordinator
    private let nowPlayingService: NowPlayingService
    private var player: AVQueuePlayer?
    private var resolvedResources: [ResolvedBookmark] = []
    private var currentIndex = 0
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?

    public init(
        bookmarkResolver: BookmarkResolving,
        audioSessionCoordinator: AudioSessionCoordinator,
        nowPlayingService: NowPlayingService
    ) {
        self.bookmarkResolver = bookmarkResolver
        self.audioSessionCoordinator = audioSessionCoordinator
        self.nowPlayingService = nowPlayingService
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    public func load(queue tracks: [Track], startIndex: Int = 0) throws {
        stopAccessingResources()
        removeTimeObserver()

        queue = tracks
        currentIndex = min(max(startIndex, 0), max(tracks.count - 1, 0))
        currentTrack = tracks.indices.contains(currentIndex) ? tracks[currentIndex] : nil
        state = PlaybackState(status: .loading, currentIndex: currentIndex)

        guard !tracks.isEmpty else {
            player = nil
            state = PlaybackState(status: .idle)
            nowPlayingService.update(track: nil, state: state)
            return
        }

        var resources: [ResolvedBookmark] = []
        do {
            for track in tracks {
                resources.append(try bookmarkResolver.resolveBookmark(for: track))
            }
        } catch {
            for resource in resources {
                bookmarkResolver.stopAccessing(resource)
            }
            state = PlaybackState(status: .failed(String(describing: error)), currentIndex: currentIndex)
            throw error
        }
        resolvedResources = resources
        let items = resources.dropFirst(currentIndex).map { AVPlayerItem(url: $0.url) }
        let newPlayer = AVQueuePlayer(items: Array(items))
        player = newPlayer
        duration = currentTrack?.duration ?? 0
        state = PlaybackState(status: .paused, currentIndex: currentIndex, progress: 0, duration: duration)
        observePlaybackTime(on: newPlayer)
        observeTrackEnd()
        nowPlayingService.update(track: currentTrack, state: state)
    }

    public func play() {
        do {
            try audioSessionCoordinator.configureForPlayback()
            player?.play()
            updateStatus(.playing)
        } catch {
            updateStatus(.failed(String(describing: error)))
        }
    }

    public func pause() {
        player?.pause()
        updateStatus(.paused)
    }

    public func seek(to progress: TimeInterval) {
        let time = CMTime(seconds: progress, preferredTimescale: 600)
        player?.seek(to: time)
        self.progress = progress
        state.progress = progress
        nowPlayingService.update(track: currentTrack, state: state)
    }

    public func skipNext() {
        guard currentIndex + 1 < queue.count else {
            updateStatus(.ended)
            return
        }
        currentIndex += 1
        player?.advanceToNextItem()
        currentTrack = queue[currentIndex]
        duration = currentTrack?.duration ?? 0
        progress = 0
        state.currentIndex = currentIndex
        state.progress = 0
        state.duration = duration
        nowPlayingService.update(track: currentTrack, state: state)
    }

    public func skipPrevious() {
        guard currentIndex > 0 else {
            seek(to: 0)
            return
        }
        let wasPlaying = state.status == .playing
        do {
            try load(queue: queue, startIndex: currentIndex - 1)
            if wasPlaying {
                play()
            }
        } catch {
            updateStatus(.failed(String(describing: error)))
        }
    }

    public func setRepeatMode(_ mode: RepeatMode) {
        state.repeatMode = mode
    }

    public func setShuffleEnabled(_ isEnabled: Bool) {
        state.isShuffleEnabled = isEnabled
    }

    private func observePlaybackTime(on player: AVQueuePlayer) {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                guard let self else { return }
                self.progress = time.seconds.isFinite ? time.seconds : 0
                self.duration = self.player?.currentItem?.duration.seconds ?? self.duration
                if !self.duration.isFinite {
                    self.duration = self.currentTrack?.duration ?? 0
                }
                self.state.progress = self.progress
                self.state.duration = self.duration
                self.nowPlayingService.update(track: self.currentTrack, state: self.state)
            }
        }
    }

    private func observeTrackEnd() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleTrackEnd()
            }
        }
    }

    private func handleTrackEnd() {
        switch state.repeatMode {
        case .one:
            seek(to: 0)
            play()
        case .all where currentIndex + 1 >= queue.count:
            try? load(queue: queue, startIndex: 0)
            play()
        default:
            skipNext()
        }
    }

    private func updateStatus(_ status: PlaybackStatus) {
        state.status = status
        nowPlayingService.update(track: currentTrack, state: state)
    }

    private func removeTimeObserver() {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    private func stopAccessingResources() {
        for resource in resolvedResources {
            bookmarkResolver.stopAccessing(resource)
        }
        resolvedResources.removeAll()
    }
}
