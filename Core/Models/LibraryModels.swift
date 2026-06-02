import Foundation

public enum TrackSort: String, Codable, Sendable {
    case title
    case artist
    case album
    case recentlyAdded
    case recentlyPlayed
}

public struct Album: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var title: String
    public var artist: String?
    public var trackCount: Int
    public var artworkID: String?

    public init(id: UUID = UUID(), title: String, artist: String? = nil, trackCount: Int = 0, artworkID: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.trackCount = trackCount
        self.artworkID = artworkID
    }
}

public struct Artist: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var trackCount: Int
    public var albumCount: Int

    public init(id: UUID = UUID(), name: String, trackCount: Int = 0, albumCount: Int = 0) {
        self.id = id
        self.name = name
        self.trackCount = trackCount
        self.albumCount = albumCount
    }
}

public struct Playlist: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var createdAt: Date
    public var updatedAt: Date
    public var trackIDs: [UUID]

    public init(id: UUID = UUID(), name: String, createdAt: Date = Date(), updatedAt: Date = Date(), trackIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.trackIDs = trackIDs
    }
}

public struct PlaybackHistoryEntry: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var trackID: UUID
    public var playedAt: Date

    public init(id: UUID = UUID(), trackID: UUID, playedAt: Date = Date()) {
        self.id = id
        self.trackID = trackID
        self.playedAt = playedAt
    }
}

public struct ImportBatch: Codable, Hashable, Sendable {
    public var importedTracks: [Track]
    public var skippedURLs: [URL]
    public var unsupportedURLs: [URL]
    public var failedURLs: [URL]

    public init(importedTracks: [Track] = [], skippedURLs: [URL] = [], unsupportedURLs: [URL] = [], failedURLs: [URL] = []) {
        self.importedTracks = importedTracks
        self.skippedURLs = skippedURLs
        self.unsupportedURLs = unsupportedURLs
        self.failedURLs = failedURLs
    }
}

public struct ScanReport: Codable, Hashable, Sendable {
    public var scannedCount: Int
    public var importedCount: Int
    public var updatedCount: Int
    public var missingCount: Int
    public var failedCount: Int

    public init(scannedCount: Int = 0, importedCount: Int = 0, updatedCount: Int = 0, missingCount: Int = 0, failedCount: Int = 0) {
        self.scannedCount = scannedCount
        self.importedCount = importedCount
        self.updatedCount = updatedCount
        self.missingCount = missingCount
        self.failedCount = failedCount
    }
}

public struct LibraryStatistics: Codable, Hashable, Sendable {
    public var trackCount: Int
    public var favoriteCount: Int
    public var playlistCount: Int
    public var totalDuration: TimeInterval

    public init(trackCount: Int = 0, favoriteCount: Int = 0, playlistCount: Int = 0, totalDuration: TimeInterval = 0) {
        self.trackCount = trackCount
        self.favoriteCount = favoriteCount
        self.playlistCount = playlistCount
        self.totalDuration = totalDuration
    }
}

