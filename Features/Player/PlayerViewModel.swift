import Foundation
import Combine
import SwiftUI

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentSong: Song?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 1.0
    @Published var shuffleMode: ShuffleMode = .off
    @Published var repeatMode: RepeatMode = .off
    @Published var showLyrics: Bool = false
    @Published var currentLyrics: Lyrics = Lyrics.empty()
    @Published var currentLyricLineIndex: Int?
    @Published var isLoadingLyrics: Bool = false
    @Published var queue: PlaybackQueue = PlaybackQueue()
    @Published var currentQueueIndex: Int = 0

    private let audioEngine = AudioEngine.shared
    private let queueManager = PlaybackQueueManager.shared
    private let lyricsEngine = LyricsSyncEngine.shared
    private let settings = SettingsStore.shared

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        loadSettings()
    }

    private func setupBindings() {
        audioEngine.$playbackState
            .receive(on: DispatchQueue.main)
            .assign(to: &$playbackState)

        audioEngine.$currentSong
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentSong)

        audioEngine.$currentTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentTime)

        audioEngine.$duration
            .receive(on: DispatchQueue.main)
            .assign(to: &$duration)

        audioEngine.$volume
            .receive(on: DispatchQueue.main)
            .assign(to: &$volume)

        queueManager.$queue
            .receive(on: DispatchQueue.main)
            .assign(to: &$queue)

        queueManager.$currentIndex
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentQueueIndex)

        lyricsEngine.$currentLyrics
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentLyrics)

        lyricsEngine.$currentLineIndex
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentLyricLineIndex)

        lyricsEngine.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoadingLyrics)

        $currentSong
            .compactMap { $0 }
            .sink { song in
                RecentPlayStore.shared.addPlay(song)
            }
            .store(in: &cancellables)
    }

    private func loadSettings() {
        shuffleMode = settings.shuffleMode ? .on : .off
        repeatMode = RepeatMode(rawValue: settings.repeatMode) ?? .off
        volume = settings.volume
        showLyrics = settings.showLyrics
    }

    func togglePlayPause() {
        audioEngine.togglePlayPause()
    }

    func play() {
        audioEngine.play()
    }

    func pause() {
        audioEngine.pause()
    }

    func stop() {
        audioEngine.stop()
    }

    func next() {
        queueManager.next()
    }

    func previous() {
        queueManager.previous()
    }

    func seek(to time: TimeInterval) {
        audioEngine.seek(to: time)
    }

    func seekToProgress(_ progress: Double) {
        let time = duration * progress
        seek(to: time)
    }

    func setVolume(_ vol: Float) {
        audioEngine.setVolume(vol)
        settings.volume = vol
    }

    func toggleShuffle() {
        queueManager.toggleShuffle()
        shuffleMode = queueManager.queue.shuffleMode
        settings.shuffleMode = shuffleMode.isActive
    }

    func toggleRepeat() {
        queueManager.toggleRepeat()
        repeatMode = queueManager.queue.repeatMode
        settings.repeatMode = repeatMode.rawValue
    }

    func toggleLyrics() {
        showLyrics.toggle()
        settings.showLyrics = showLyrics
    }

    func play(songs: [Song], startingAt index: Int = 0) {
        queueManager.play(songs: songs, startingAt: index)
    }

    func play(song: Song, in queue: [Song]) {
        queueManager.play(song: song, in: queue)
    }

    func addToQueue(_ songs: [Song]) {
        queueManager.addToQueue(songs)
    }

    func addToQueue(_ song: Song) {
        queueManager.addToQueue(song)
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var formattedCurrentTime: String {
        currentTime.formattedTime
    }

    var formattedDuration: String {
        duration.formattedTime
    }

    var formattedRemainingTime: String {
        let remaining = max(0, duration - currentTime)
        return "-\(remaining.formattedTime)"
    }
}
