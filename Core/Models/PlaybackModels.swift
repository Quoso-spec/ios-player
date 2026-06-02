import Foundation

public enum PlaybackStatus: Equatable, Codable, Sendable {
    case idle
    case loading
    case playing
    case paused
    case buffering
    case ended
    case failed(String)
}

public enum RepeatMode: String, Codable, Sendable {
    case off
    case one
    case all
}

public struct PlaybackState: Equatable, Codable, Sendable {
    public var status: PlaybackStatus
    public var currentIndex: Int
    public var progress: TimeInterval
    public var duration: TimeInterval
    public var repeatMode: RepeatMode
    public var isShuffleEnabled: Bool

    public init(
        status: PlaybackStatus = .idle,
        currentIndex: Int = 0,
        progress: TimeInterval = 0,
        duration: TimeInterval = 0,
        repeatMode: RepeatMode = .off,
        isShuffleEnabled: Bool = false
    ) {
        self.status = status
        self.currentIndex = currentIndex
        self.progress = progress
        self.duration = duration
        self.repeatMode = repeatMode
        self.isShuffleEnabled = isShuffleEnabled
    }
}

public struct EqualizerBand: Codable, Hashable, Sendable {
    public var frequency: Double
    public var gain: Double

    public init(frequency: Double, gain: Double = 0) {
        self.frequency = frequency
        self.gain = gain
    }
}

public struct AdvancedAudioConfiguration: Codable, Hashable, Sendable {
    public var equalizerBands: [EqualizerBand]
    public var crossfadeDuration: TimeInterval
    public var replayGainEnabled: Bool
    public var volumeNormalizationEnabled: Bool
    public var sleepTimerEndDate: Date?

    public init(
        equalizerBands: [EqualizerBand] = [],
        crossfadeDuration: TimeInterval = 0,
        replayGainEnabled: Bool = false,
        volumeNormalizationEnabled: Bool = false,
        sleepTimerEndDate: Date? = nil
    ) {
        self.equalizerBands = equalizerBands
        self.crossfadeDuration = crossfadeDuration
        self.replayGainEnabled = replayGainEnabled
        self.volumeNormalizationEnabled = volumeNormalizationEnabled
        self.sleepTimerEndDate = sleepTimerEndDate
    }
}

