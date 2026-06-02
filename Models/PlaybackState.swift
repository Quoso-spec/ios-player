import Foundation

enum PlaybackState: Equatable {
    case stopped
    case playing
    case paused
    case loading
    case error(String)

    var isPlaying: Bool {
        self == .playing
    }

    var canPlay: Bool {
        switch self {
        case .stopped, .paused:
            return true
        default:
            return false
        }
    }
}

enum RepeatMode: Int, CaseIterable {
    case off = 0
    case all = 1
    case one = 2

    var icon: String {
        switch self {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    var isActive: Bool {
        self != .off
    }

    func next() -> RepeatMode {
        RepeatMode(rawValue: (rawValue + 1) % 3) ?? .off
    }
}

enum SortOrder: String, CaseIterable {
    case title = "Title"
    case artist = "Artist"
    case album = "Album"
    case dateAdded = "Date Added"
    case duration = "Duration"

    var icon: String {
        switch self {
        case .title: return "textformat"
        case .artist: return "person"
        case .album: return "square.stack"
        case .dateAdded: return "calendar"
        case .duration: return "clock"
        }
    }
}

enum ShuffleMode {
    case off
    case on

    var isActive: Bool {
        self == .on
    }

    mutating func toggle() {
        self = isActive ? .off : .on
    }
}

struct PlaybackQueue {
    var originalOrder: [Song] = []
    var currentIndex: Int = 0
    var shuffleMode: ShuffleMode = .off
    var repeatMode: RepeatMode = .off

    var currentSong: Song? {
        guard currentIndex >= 0 && currentIndex < shuffledQueue.count else { return nil }
        return shuffledQueue[currentIndex]
    }

    var shuffledQueue: [Song] {
        guard shuffleMode.isActive else { return originalOrder }
        guard originalOrder.count > 1 else { return originalOrder }

        var shuffled = originalOrder
        if let current = currentSong, let idx = shuffled.firstIndex(where: { $0.id == current.id }) {
            shuffled.remove(at: idx)
            shuffled.shuffle()
            shuffled.insert(current, at: 0)
        } else {
            shuffled.shuffle()
        }
        return shuffled
    }

    var hasNext: Bool {
        currentIndex < shuffledQueue.count - 1 || repeatMode == .all
    }

    var hasPrevious: Bool {
        currentIndex > 0 || repeatMode == .all
    }

    mutating func next() {
        if repeatMode == .one {
            return
        }
        if currentIndex < shuffledQueue.count - 1 {
            currentIndex += 1
        } else if repeatMode == .all {
            currentIndex = 0
        }
    }

    mutating func previous() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else if repeatMode == .all {
            currentIndex = shuffledQueue.count - 1
        }
    }

    mutating func play(at index: Int) {
        guard index >= 0 && index < shuffledQueue.count else { return }
        currentIndex = index
    }

    mutating func setQueue(_ songs: [Song], startingAt index: Int = 0) {
        originalOrder = songs
        currentIndex = index
    }
}
