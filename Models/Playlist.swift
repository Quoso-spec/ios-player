import Foundation

struct Playlist: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var description: String
    var songIds: [String]
    var artworkData: Data?
    var dateCreated: Date
    var dateModified: Date
    var isFavorite: Bool

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        songIds: [String] = [],
        artworkData: Data? = nil,
        dateCreated: Date = Date(),
        dateModified: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.songIds = songIds
        self.artworkData = artworkData
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.isFavorite = isFavorite
    }

    var songCount: Int {
        songIds.count
    }

    mutating func addSong(_ songId: String) {
        guard !songIds.contains(songId) else { return }
        songIds.append(songId)
        dateModified = Date()
    }

    mutating func removeSong(_ songId: String) {
        songIds.removeAll { $0 == songId }
        dateModified = Date()
    }

    mutating func moveSong(from source: IndexSet, to destination: Int) {
        songIds.move(fromOffsets: source, toOffset: destination)
        dateModified = Date()
    }

    static func placeholder() -> Playlist {
        Playlist(name: "New Playlist")
    }
}
