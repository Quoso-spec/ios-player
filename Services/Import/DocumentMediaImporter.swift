import Foundation
import UIKit
import UniformTypeIdentifiers

@MainActor
public final class DocumentMediaImporter: NSObject, MediaImporter, UIDocumentPickerDelegate {
    private let libraryStore: any LibraryStore
    private let metadataService: any MetadataService
    private let bookmarkResolver: BookmarkResolving
    private var pickerContinuation: CheckedContinuation<[URL], Error>?

    private let supportedAudioTypes: [UTType] = [
        .audio,
        UTType(filenameExtension: "mp3") ?? .audio,
        UTType(filenameExtension: "m4a") ?? .audio,
        UTType(filenameExtension: "aac") ?? .audio,
        UTType(filenameExtension: "wav") ?? .audio,
        UTType(filenameExtension: "flac") ?? .audio,
        UTType(filenameExtension: "alac") ?? .audio
    ]

    public init(
        libraryStore: any LibraryStore,
        metadataService: any MetadataService,
        bookmarkResolver: BookmarkResolving
    ) {
        self.libraryStore = libraryStore
        self.metadataService = metadataService
        self.bookmarkResolver = bookmarkResolver
    }

    public func importFiles() async throws -> ImportBatch {
        let urls = try await pick(contentTypes: supportedAudioTypes, allowsMultipleSelection: true)
        return try await importAudioURLs(urls)
    }

    public func importFolder() async throws -> ImportBatch {
        let urls = try await pick(contentTypes: [.folder], allowsMultipleSelection: false)
        var audioURLs: [URL] = []
        for folderURL in urls {
            let didAccess = folderURL.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    folderURL.stopAccessingSecurityScopedResource()
                }
            }
            audioURLs.append(contentsOf: try Self.audioFiles(in: folderURL))
        }
        return try await importAudioURLs(audioURLs)
    }

    public func rescanLibrary() async throws -> ScanReport {
        let tracks = try await libraryStore.tracks(sort: .title)
        var report = ScanReport(scannedCount: tracks.count)

        for track in tracks {
            do {
                let resolved = try bookmarkResolver.resolveBookmark(for: track)
                defer {
                    bookmarkResolver.stopAccessing(resolved)
                }
                if FileManager.default.fileExists(atPath: resolved.url.path) {
                    var refreshed = track
                    let metadata = try await metadataService.metadata(for: resolved.url)
                    refreshed.title = metadata.title ?? refreshed.title
                    refreshed.artist = metadata.artist ?? refreshed.artist
                    refreshed.album = metadata.album ?? refreshed.album
                    refreshed.albumArtist = metadata.albumArtist ?? refreshed.albumArtist
                    refreshed.duration = metadata.duration > 0 ? metadata.duration : refreshed.duration
                    refreshed.format = metadata.format ?? refreshed.format
                    refreshed.bitrate = metadata.bitrate ?? refreshed.bitrate
                    refreshed.sampleRate = metadata.sampleRate ?? refreshed.sampleRate
                    refreshed.updatedAt = Date()
                    refreshed.isMissing = false
                    try await libraryStore.upsertTrack(refreshed)
                    report.updatedCount += 1
                } else {
                    try await libraryStore.markTrackMissing(id: track.id, isMissing: true)
                    report.missingCount += 1
                }
            } catch {
                report.failedCount += 1
            }
        }

        return report
    }

    public func resolveBookmark(for track: Track) throws -> URL {
        try bookmarkResolver.resolveBookmark(for: track).url
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pickerContinuation?.resume(returning: urls)
        pickerContinuation = nil
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        pickerContinuation?.resume(throwing: MediaImporterError.cancelled)
        pickerContinuation = nil
    }

    private func pick(contentTypes: [UTType], allowsMultipleSelection: Bool) async throws -> [URL] {
        guard let presenter = UIViewController.saltTopMostViewController() else {
            throw MediaImporterError.presentationUnavailable
        }
        return try await withCheckedThrowingContinuation { continuation in
            pickerContinuation = continuation
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: false)
            picker.allowsMultipleSelection = allowsMultipleSelection
            picker.delegate = self
            presenter.present(picker, animated: true)
        }
    }

    private func importAudioURLs(_ urls: [URL]) async throws -> ImportBatch {
        var batch = ImportBatch()

        for url in urls {
            guard Self.isSupportedAudioURL(url) else {
                batch.unsupportedURLs.append(url)
                continue
            }

            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let possibleMatches = try await libraryStore.searchTracks(query: url.lastPathComponent)
                if possibleMatches.contains(where: { $0.originalFilePathHint == url.path }) {
                    batch.skippedURLs.append(url)
                    continue
                }

                let bookmark = try bookmarkResolver.bookmark(for: url)
                let metadata = try await metadataService.metadata(for: url)
                let track = Track.makeImportedTrack(bookmark: bookmark, fileURL: url, metadata: metadata)
                try await libraryStore.upsertTrack(track)
                batch.importedTracks.append(track)
            } catch {
                batch.failedURLs.append(url)
            }
        }

        return batch
    }

    private static func isSupportedAudioURL(_ url: URL) -> Bool {
        let supportedExtensions = ["mp3", "m4a", "aac", "wav", "flac", "alac"]
        return supportedExtensions.contains(url.pathExtension.lowercased())
    }

    private static func audioFiles(in folderURL: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: folderURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var urls: [URL] = []
        for case let url as URL in enumerator where isSupportedAudioURL(url) {
            urls.append(url)
        }
        return urls
    }
}

private extension UIViewController {
    static func saltTopMostViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap(\.windows).first { $0.isKeyWindow }
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
