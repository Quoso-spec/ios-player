import AVFoundation
import Foundation

public protocol LyricsProvider {
    func findLocalLyrics(for track: Track) async throws -> LyricsDocument?
    func findEmbeddedLyrics(for track: Track) async throws -> LyricsDocument?
    func searchOnlineLyrics(for query: LyricsSearchQuery) async throws -> [LyricsSearchResult]
    func saveLyrics(_ lyrics: LyricsDocument, for track: Track) async throws
    func adjustOffset(_ offset: TimeInterval, for track: Track) async throws
}

public final class DefaultLyricsProvider: LyricsProvider {
    private let bookmarkResolver: BookmarkResolving
    private let storageDirectory: URL

    public init(bookmarkResolver: BookmarkResolving, storageDirectory: URL) {
        self.bookmarkResolver = bookmarkResolver
        self.storageDirectory = storageDirectory
    }

    public func findLocalLyrics(for track: Track) async throws -> LyricsDocument? {
        let resolved = try bookmarkResolver.resolveBookmark(for: track)
        defer {
            bookmarkResolver.stopAccessing(resolved)
        }

        let localURL = resolved.url.deletingPathExtension().appendingPathExtension("lrc")
        guard FileManager.default.fileExists(atPath: localURL.path) else {
            return try savedLyrics(for: track)
        }
        let text = try String(contentsOf: localURL, encoding: .utf8)
        return LRCParser.parse(text: text, source: .localLRC)
    }

    public func findEmbeddedLyrics(for track: Track) async throws -> LyricsDocument? {
        let resolved = try bookmarkResolver.resolveBookmark(for: track)
        defer {
            bookmarkResolver.stopAccessing(resolved)
        }
        let asset = AVURLAsset(url: resolved.url)
        let metadata = try await asset.load(.commonMetadata)
        let lyricText = metadata.compactMap(\.stringValue).first { $0.contains("[") && $0.contains("]") }
        guard let lyricText else {
            return nil
        }
        return LRCParser.parse(text: lyricText, source: .embedded)
    }

    public func searchOnlineLyrics(for query: LyricsSearchQuery) async throws -> [LyricsSearchResult] {
        []
    }

    public func saveLyrics(_ lyrics: LyricsDocument, for track: Track) async throws {
        try FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        let url = lyricsURL(for: track)
        try lyrics.rawText.write(to: url, atomically: true, encoding: .utf8)
    }

    public func adjustOffset(_ offset: TimeInterval, for track: Track) async throws {
        guard var lyrics = try await savedLyrics(for: track) else {
            return
        }
        lyrics.offset = offset
        try await saveLyrics(lyrics, for: track)
    }

    private func savedLyrics(for track: Track) throws -> LyricsDocument? {
        let url = lyricsURL(for: track)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let text = try String(contentsOf: url, encoding: .utf8)
        return LRCParser.parse(text: text, source: .manual)
    }

    private func lyricsURL(for track: Track) -> URL {
        storageDirectory.appendingPathComponent(track.id.uuidString).appendingPathExtension("lrc")
    }
}

