import Foundation
import MediaPlayer

public enum SystemMediaLibraryStatus: Equatable, Sendable {
    case unsupported
    case notDetermined
    case denied
    case authorized
}

public struct SystemMediaLibrarySnapshot: Codable, Hashable, Sendable {
    public var tracks: [Track]
    public var scannedAt: Date

    public init(tracks: [Track] = [], scannedAt: Date = Date()) {
        self.tracks = tracks
        self.scannedAt = scannedAt
    }
}

public protocol SystemMediaLibraryProviding {
    func authorizationStatus() -> SystemMediaLibraryStatus
    func requestAuthorization() async -> SystemMediaLibraryStatus
    func scanSystemLibrary() async throws -> SystemMediaLibrarySnapshot
}

public final class PlaceholderSystemMediaLibraryProvider: SystemMediaLibraryProviding {
    public init() {}

    public func authorizationStatus() -> SystemMediaLibraryStatus {
        switch MPMediaLibrary.authorizationStatus() {
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .unsupported
        }
    }

    public func requestAuthorization() async -> SystemMediaLibraryStatus {
        await withCheckedContinuation { continuation in
            MPMediaLibrary.requestAuthorization { status in
                switch status {
                case .notDetermined:
                    continuation.resume(returning: .notDetermined)
                case .denied, .restricted:
                    continuation.resume(returning: .denied)
                case .authorized:
                    continuation.resume(returning: .authorized)
                @unknown default:
                    continuation.resume(returning: .unsupported)
                }
            }
        }
    }

    public func scanSystemLibrary() async throws -> SystemMediaLibrarySnapshot {
        SystemMediaLibrarySnapshot()
    }
}

