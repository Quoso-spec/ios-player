import Foundation

struct Artist: Identifiable, Hashable {
    let id: String
    var name: String
    var albumIds: [String]
    var songIds: [String]
    var artworkData: Data?

    init(
        id: String = UUID().uuidString,
        name: String,
        albumIds: [String] = [],
        songIds: [String] = [],
        artworkData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.albumIds = albumIds
        self.songIds = songIds
        self.artworkData = artworkData
    }

    var albumCount: Int {
        albumIds.count
    }

    var songCount: Int {
        songIds.count
    }

    static func placeholder() -> Artist {
        Artist(name: "Unknown Artist")
    }
}
