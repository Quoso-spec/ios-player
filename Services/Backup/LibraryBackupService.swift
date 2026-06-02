import Foundation

public struct LibraryBackupManifest: Codable, Hashable, Sendable {
    public var createdAt: Date
    public var appVersion: String
    public var databaseFileName: String

    public init(createdAt: Date = Date(), appVersion: String = "0.1.0", databaseFileName: String = "Library.sqlite") {
        self.createdAt = createdAt
        self.appVersion = appVersion
        self.databaseFileName = databaseFileName
    }
}

public protocol LibraryBackupProviding {
    func exportBackup(to destinationDirectory: URL) async throws -> URL
    func restoreBackup(from backupDirectory: URL) async throws
}

public final class FileLibraryBackupService: LibraryBackupProviding {
    private let databaseURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(databaseURL: URL) {
        self.databaseURL = databaseURL
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public func exportBackup(to destinationDirectory: URL) async throws -> URL {
        let backupDirectory = destinationDirectory
            .appendingPathComponent("SaltMusicBackup-\(Self.timestamp())", isDirectory: true)
        try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)

        for sourceURL in Self.databaseFiles(for: databaseURL) {
            let destinationURL = backupDirectory.appendingPathComponent(sourceURL.lastPathComponent)
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        }

        let manifest = LibraryBackupManifest(databaseFileName: databaseURL.lastPathComponent)
        let manifestData = try encoder.encode(manifest)
        try manifestData.write(to: backupDirectory.appendingPathComponent("manifest.json"), options: .atomic)
        return backupDirectory
    }

    public func restoreBackup(from backupDirectory: URL) async throws {
        let manifestURL = backupDirectory.appendingPathComponent("manifest.json")
        let manifest = try decoder.decode(LibraryBackupManifest.self, from: Data(contentsOf: manifestURL))
        for backupURL in Self.databaseFiles(for: backupDirectory.appendingPathComponent(manifest.databaseFileName)) {
            let destination = databaseURL.deletingLastPathComponent().appendingPathComponent(backupURL.lastPathComponent)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: backupURL, to: destination)
        }
    }

    private static func timestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
    }

    private static func databaseFiles(for url: URL) -> [URL] {
        [url, URL(fileURLWithPath: url.path + "-wal"), URL(fileURLWithPath: url.path + "-shm")]
            .filter { FileManager.default.fileExists(atPath: $0.path) }
    }
}
