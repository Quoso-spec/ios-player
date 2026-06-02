import AVFoundation
import Foundation

public enum AudioSessionCoordinatorError: Error {
    case activationFailed(Error)
}

public final class AudioSessionCoordinator {
    public init() {}

    public func configureForPlayback() throws {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try session.setActive(true)
        } catch {
            throw AudioSessionCoordinatorError.activationFailed(error)
        }
    }

    public func deactivate() {
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }
}

