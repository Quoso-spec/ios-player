import Foundation
import Combine
import SwiftUI

@MainActor
final class QueueViewModel: ObservableObject {
    @Published var queue: PlaybackQueue = PlaybackQueue()
    @Published var currentIndex: Int = 0

    private let queueManager = PlaybackQueueManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        queueManager.$queue
            .receive(on: DispatchQueue.main)
            .assign(to: &$queue)

        queueManager.$currentIndex
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentIndex)
    }

    var currentSong: Song? {
        queue.currentSong
    }

    var isEmpty: Bool {
        queue.originalOrder.isEmpty
    }

    var songCount: Int {
        queue.originalOrder.count
    }

    func playAt(index: Int) {
        queueManager.playAt(index: index)
    }

    func removeAt(offsets: IndexSet) {
        for offset in offsets {
            queueManager.removeFromQueue(at: offset)
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        queueManager.moveItem(from: source, to: destination)
    }

    func clearQueue() {
        queueManager.clearQueue()
    }
}
