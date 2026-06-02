import Foundation
import UIKit

public struct DiagnosticsSnapshot: Codable, Hashable, Sendable {
    public var createdAt: Date
    public var appVersion: String
    public var databasePath: String
    public var systemVersion: String
    public var deviceModel: String

    public init(
        createdAt: Date = Date(),
        appVersion: String = "0.1.0",
        databasePath: String,
        systemVersion: String,
        deviceModel: String
    ) {
        self.createdAt = createdAt
        self.appVersion = appVersion
        self.databasePath = databasePath
        self.systemVersion = systemVersion
        self.deviceModel = deviceModel
    }
}

@MainActor
public protocol DiagnosticsProviding {
    func makeSnapshot() async -> DiagnosticsSnapshot
    func exportSnapshot(to destinationDirectory: URL) async throws -> URL
}

@MainActor
public final class DiagnosticsService: DiagnosticsProviding {
    private let databaseURL: URL
    private let encoder = JSONEncoder()

    public init(databaseURL: URL) {
        self.databaseURL = databaseURL
        encoder.dateEncodingStrategy = .iso8601
    }

    public func makeSnapshot() async -> DiagnosticsSnapshot {
        DiagnosticsSnapshot(
            databasePath: databaseURL.path,
            systemVersion: UIDevice.current.systemVersion,
            deviceModel: UIDevice.current.model
        )
    }

    public func exportSnapshot(to destinationDirectory: URL) async throws -> URL {
        try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
        let snapshot = await makeSnapshot()
        let data = try encoder.encode(snapshot)
        let url = destinationDirectory.appendingPathComponent("diagnostics.json")
        try data.write(to: url, options: .atomic)
        return url
    }
}
