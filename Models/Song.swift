import Foundation

struct Song: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var artist: String
    var album: String
    var albumArtist: String
    var duration: TimeInterval
    var trackNumber: Int
    var discNumber: Int
    var year: Int
    var genre: String
    var filePath: String
    var fileSize: Int64
    var artworkData: Data?
    var dateAdded: Date
    var lastPlayed: Date?
    var playCount: Int
    var isFavorite: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        artist: String = "Unknown Artist",
        album: String = "Unknown Album",
        albumArtist: String = "",
        duration: TimeInterval = 0,
        trackNumber: Int = 0,
        discNumber: Int = 1,
        year: Int = 0,
        genre: String = "",
        filePath: String,
        fileSize: Int64 = 0,
        artworkData: Data? = nil,
        dateAdded: Date = Date(),
        lastPlayed: Date? = nil,
        playCount: Int = 0,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.albumArtist = albumArtist.isEmpty ? artist : albumArtist
        self.duration = duration
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.year = year
        self.genre = genre
        self.filePath = filePath
        self.fileSize = fileSize
        self.artworkData = artworkData
        self.dateAdded = dateAdded
        self.lastPlayed = lastPlayed
        self.playCount = playCount
        self.isFavorite = isFavorite
    }

    var fileURL: URL {
        URL(fileURLWithPath: filePath)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }

    static func placeholder() -> Song {
        Song(
            title: "Unknown Title",
            artist: "Unknown Artist",
            album: "Unknown Album",
            filePath: ""
        )
    }
}

extension Song {
    static let supportedExtensions: Set<String> = ["mp3", "m4a", "flac", "aac", "wav", "aiff", "alac", "ogg", "opus"]
}
