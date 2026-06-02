import Foundation
import Combine

final class PlaybackQueueManager: ObservableObject {
    static let shared = PlaybackQueueManager()

    @Published var queue: PlaybackQueue = PlaybackQueue()
    @Published var currentIndex: Int = 0

    private var audioEngine: AudioEngine { AudioEngine.shared }
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    var currentSong: Song? {
        queue.currentSong
    }

    var hasNext: Bool {
        queue.hasNext
    }

    var hasPrevious: Bool {
        queue.hasPrevious
    }

    func play(songs: [Song], startingAt index: Int = 0) {
        guard !songs.isEmpty else { return }
        queue.setQueue(songs, startingAt: index)
        if let song = queue.currentSong {
            audioEngine.load(song: song)
            audioEngine.play()
        }
    }

    func play(song: Song, in queue: [Song]) {
        guard let index = queue.firstIndex(where: { $0.id == song.id }) else { return }
        self.queue.setQueue(queue, startingAt: index)
        audioEngine.load(song: song)
        audioEngine.play()
    }

    func addToQueue(_ songs: [Song]) {
        queue.originalOrder.append(contentsOf: songs)
    }

    func addToQueue(_ song: Song) {
        queue.originalOrder.append(song)
    }

    func removeFromQueue(at index: Int) {
        guard index >= 0 && index < queue.originalOrder.count else { return }
        queue.originalOrder.remove(at: index)

        if index < currentIndex {
            currentIndex -= 1
        } else if index == currentIndex {
            if currentIndex >= queue.originalOrder.count {
                currentIndex = max(0, queue.originalOrder.count - 1)
            }
            if let song = self.currentSong {
                audioEngine.load(song: song)
                if audioEngine.playbackState == .playing {
                    audioEngine.play()
                }
            }
        }
    }

    func clearQueue() {
        queue.originalOrder.removeAll()
        currentIndex = 0
        audioEngine.stop()
    }

    func next() {
        guard hasNext else {
            if queue.repeatMode == .one {
                seekToStart()
            }
            return
        }

        queue.next()
        currentIndex = queue.currentIndex
        if let song = currentSong {
            audioEngine.load(song: song)
            audioEngine.play()
        }
    }

    func previous() {
        if audioEngine.currentTime > 3 {
            seekToStart()
            return
        }

        guard hasPrevious else { return }
        queue.previous()
        currentIndex = queue.currentIndex
        if let song = currentSong {
            audioEngine.load(song: song)
            audioEngine.play()
        }
    }

    func seekToStart() {
        audioEngine.seek(to: 0)
    }

    func toggleShuffle() {
        queue.shuffleMode.toggle()
    }

    func toggleRepeat() {
        queue.repeatMode = queue.repeatMode.next()
    }

    func setRepeatMode(_ mode: RepeatMode) {
        queue.repeatMode = mode
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        queue.originalOrder.move(fromOffsets: source, toOffset: destination)
    }

    func playAt(index: Int) {
        queue.play(at: index)
        currentIndex = index
        if let song = currentSong {
            audioEngine.load(song: song)
            audioEngine.play()
        }
    }
}
