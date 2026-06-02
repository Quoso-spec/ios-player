import Foundation
import Combine

final class LyricsSyncEngine: ObservableObject {
    static let shared = LyricsSyncEngine()

    @Published private(set) var currentLyrics: Lyrics = Lyrics.empty()
    @Published private(set) var currentLineIndex: Int?
    @Published private(set) var isLoading: Bool = false

    private let lrcParser = LrcParser.shared
    private let enhancedParser = EnhancedLrcParser.shared

    private var cancellables = Set<AnyCancellable>()
    private var currentSongId: String?

    private init() {
        setupBindings()
    }

    private func setupBindings() {
        AudioEngine.shared.$currentTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.updateCurrentLine(at: time)
            }
            .store(in: &cancellables)

        AudioEngine.shared.$currentSong
            .receive(on: DispatchQueue.main)
            .sink { [weak self] song in
                guard let song = song else {
                    self?.currentLyrics = Lyrics.empty()
                    self?.currentLineIndex = nil
                    return
                }
                Task {
                    await self?.loadLyrics(for: song)
                }
            }
            .store(in: &cancellables)
    }

    func loadLyrics(for song: Song) async {
        guard song.id != currentSongId else { return }

        await MainActor.run {
            isLoading = true
            currentSongId = song.id
        }

        let lyrics = await lrcParser.loadLyrics(for: song)

        await MainActor.run {
            currentLyrics = lyrics
            currentLineIndex = nil
            isLoading = false
        }
    }

    func loadLyrics(from url: URL) async {
        let lyrics = await lrcParser.parse(from: url)

        await MainActor.run {
            currentLyrics = lyrics
            currentLineIndex = nil
            currentSongId = nil
        }
    }

    private func updateCurrentLine(at time: TimeInterval) {
        let newIndex = currentLyrics.lineIndex(at: time)

        if newIndex != currentLineIndex {
            currentLineIndex = newIndex
        }
    }

    func lineAfterCurrent() -> LyricLine? {
        guard let current = currentLineIndex,
              current + 1 < currentLyrics.lines.count else {
            return nil
        }
        return currentLyrics.lines[current + 1]
    }

    func timeUntilNextLine() -> TimeInterval? {
        guard let current = currentLineIndex,
              let next = lineAfterCurrent() else {
            return nil
        }
        let currentTime = AudioEngine.shared.currentTime
        return next.time - currentTime
    }

    func reset() {
        currentLyrics = Lyrics.empty()
        currentLineIndex = nil
        currentSongId = nil
    }
}
