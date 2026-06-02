import Foundation

public struct MetadataOverride: Codable, Hashable, Sendable {
    public var title: String?
    public var artist: String?
    public var album: String?
    public var albumArtist: String?
    public var artworkID: String?
    public var lyricsID: String?

    public init(
        title: String? = nil,
        artist: String? = nil,
        album: String? = nil,
        albumArtist: String? = nil,
        artworkID: String? = nil,
        lyricsID: String? = nil
    ) {
        self.title = title
        self.artist = artist
        self.album = album
        self.albumArtist = albumArtist
        self.artworkID = artworkID
        self.lyricsID = lyricsID
    }
}

public struct TrackMetadata: Codable, Hashable, Sendable {
    public var title: String?
    public var artist: String?
    public var album: String?
    public var albumArtist: String?
    public var duration: TimeInterval
    public var format: String?
    public var bitrate: Int?
    public var sampleRate: Int?
    public var artworkData: Data?

    public init(
        title: String? = nil,
        artist: String? = nil,
        album: String? = nil,
        albumArtist: String? = nil,
        duration: TimeInterval = 0,
        format: String? = nil,
        bitrate: Int? = nil,
        sampleRate: Int? = nil,
        artworkData: Data? = nil
    ) {
        self.title = title
        self.artist = artist
        self.album = album
        self.albumArtist = albumArtist
        self.duration = duration
        self.format = format
        self.bitrate = bitrate
        self.sampleRate = sampleRate
        self.artworkData = artworkData
    }
}

public struct Track: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var sourceURLBookmark: Data
    public var fileName: String
    public var originalFilePathHint: String?
    public var title: String?
    public var artist: String?
    public var album: String?
    public var albumArtist: String?
    public var duration: TimeInterval
    public var format: String?
    public var bitrate: Int?
    public var sampleRate: Int?
    public var artworkID: String?
    public var lyricsID: String?
    public var metadataOverride: MetadataOverride?
    public var isFavorite: Bool
    public var playCount: Int
    public var addedAt: Date
    public var updatedAt: Date
    public var lastPlayedAt: Date?
    public var isMissing: Bool

    public init(
        id: UUID = UUID(),
        sourceURLBookmark: Data,
        fileName: String,
        originalFilePathHint: String? = nil,
        title: String? = nil,
        artist: String? = nil,
        album: String? = nil,
        albumArtist: String? = nil,
        duration: TimeInterval = 0,
        format: String? = nil,
        bitrate: Int? = nil,
        sampleRate: Int? = nil,
        artworkID: String? = nil,
        lyricsID: String? = nil,
        metadataOverride: MetadataOverride? = nil,
        isFavorite: Bool = false,
        playCount: Int = 0,
        addedAt: Date = Date(),
        updatedAt: Date = Date(),
        lastPlayedAt: Date? = nil,
        isMissing: Bool = false
    ) {
        self.id = id
        self.sourceURLBookmark = sourceURLBookmark
        self.fileName = fileName
        self.originalFilePathHint = originalFilePathHint
        self.title = title
        self.artist = artist
        self.album = album
        self.albumArtist = albumArtist
        self.duration = duration
        self.format = format
        self.bitrate = bitrate
        self.sampleRate = sampleRate
        self.artworkID = artworkID
        self.lyricsID = lyricsID
        self.metadataOverride = metadataOverride
        self.isFavorite = isFavorite
        self.playCount = playCount
        self.addedAt = addedAt
        self.updatedAt = updatedAt
        self.lastPlayedAt = lastPlayedAt
        self.isMissing = isMissing
    }

    public var displayTitle: String {
        metadataOverride?.title ?? title ?? fileName
    }

    public var displayArtist: String {
        metadataOverride?.artist ?? artist ?? "Unknown Artist"
    }

    public var displayAlbum: String {
        metadataOverride?.album ?? album ?? "Unknown Album"
    }

    public static func makeImportedTrack(
        bookmark: Data,
        fileURL: URL,
        metadata: TrackMetadata
    ) -> Track {
        Track(
            sourceURLBookmark: bookmark,
            fileName: fileURL.lastPathComponent,
            originalFilePathHint: fileURL.path,
            title: metadata.title,
            artist: metadata.artist,
            album: metadata.album,
            albumArtist: metadata.albumArtist,
            duration: metadata.duration,
            format: metadata.format ?? fileURL.pathExtension.lowercased(),
            bitrate: metadata.bitrate,
            sampleRate: metadata.sampleRate
        )
    }
}

