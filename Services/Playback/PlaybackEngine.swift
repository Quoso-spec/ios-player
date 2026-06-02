import Foundation

@MainActor
public protocol PlaybackEngine: AnyObject {
    var state: PlaybackState { get }
    var currentTrack: Track? { get }
    var progress: TimeInterval { get }
    var duration: TimeInterval { get }
    var queue: [Track] { get }

    func load(queue: [Track], startIndex: Int) throws
    func play()
    func pause()
    func seek(to progress: TimeInterval)
    func skipNext()
    func skipPrevious()
    func setRepeatMode(_ mode: RepeatMode)
    func setShuffleEnabled(_ isEnabled: Bool)
}

