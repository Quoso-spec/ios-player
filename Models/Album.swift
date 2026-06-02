import Foundation

struct Album: Identifiable, Hashable {
    let id: String
    var name: String
    var artist: String
    var year: Int
    var songIds: [String]
    var artworkData: Data?
    var dateAdded: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        artist: String,
        year: Int = 0,
        songIds: [String] = [],
        artworkData: Data? = nil,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.artist = artist
        self.year = year
        self.songIds = songIds
        self.artworkData = artworkData
        self.dateAdded = dateAdded
    }

    var songCount: Int {
        songIds.count
    }

    func songs(from library: MusicLibrary) -> [Song] {
        songIds.compactMap { id in
            library.allSongs.first { $0.id == id }
        }
    }

    static func placeholder() -> Album {
        Album(name: "Unknown Album", artist: "Unknown Artist")
    }
}
