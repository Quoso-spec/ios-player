import Foundation

public enum LyricsSource: String, Codable, Sendable {
    case localLRC
    case embedded
    case online
    case manual
}

public struct LyricLine: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var time: TimeInterval
    public var text: String

    public init(id: UUID = UUID(), time: TimeInterval, text: String) {
        self.id = id
        self.time = time
        self.text = text
    }
}

public struct LyricsDocument: Codable, Hashable, Sendable {
    public var id: UUID
    public var source: LyricsSource
    public var title: String?
    public var artist: String?
    public var offset: TimeInterval
    public var lines: [LyricLine]
    public var rawText: String

    public init(
        id: UUID = UUID(),
        source: LyricsSource,
        title: String? = nil,
        artist: String? = nil,
        offset: TimeInterval = 0,
        lines: [LyricLine] = [],
        rawText: String = ""
    ) {
        self.id = id
        self.source = source
        self.title = title
        self.artist = artist
        self.offset = offset
        self.lines = lines
        self.rawText = rawText
    }

    public func activeLine(at progress: TimeInterval) -> LyricLine? {
        let adjusted = progress + offset
        return lines.last { $0.time <= adjusted }
    }
}

public struct LyricsSearchQuery: Codable, Hashable, Sendable {
    public var title: String
    public var artist: String?
    public var album: String?
    public var duration: TimeInterval?

    public init(title: String, artist: String? = nil, album: String? = nil, duration: TimeInterval? = nil) {
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
    }
}

public struct LyricsSearchResult: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var providerName: String
    public var title: String
    public var artist: String?
    public var preview: String

    public init(id: UUID = UUID(), providerName: String, title: String, artist: String? = nil, preview: String = "") {
        self.id = id
        self.providerName = providerName
        self.title = title
        self.artist = artist
        self.preview = preview
    }
}

