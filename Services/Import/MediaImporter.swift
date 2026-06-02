import Foundation

@MainActor
public protocol MediaImporter {
    func importFiles() async throws -> ImportBatch
    func importFolder() async throws -> ImportBatch
    func rescanLibrary() async throws -> ScanReport
    func resolveBookmark(for track: Track) throws -> URL
}

public enum MediaImporterError: Error {
    case presentationUnavailable
    case cancelled
}
