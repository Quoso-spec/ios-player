import Foundation
import Combine

final class PlaylistStore: ObservableObject {
    static let shared = PlaylistStore()

    @Published private(set) var playlists: [Playlist] = []

    private let databaseManager = DatabaseManager.shared

    private init() {
        loadPlaylists()
    }

    func loadPlaylists() {
        playlists = databaseManager.loadPlaylists()
    }

    func createPlaylist(name: String, description: String = "") -> Playlist {
        let playlist = Playlist(
            name: name,
            description: description
        )
        save(playlist)
        return playlist
    }

    func save(_ playlist: Playlist) {
        databaseManager.savePlaylist(playlist)
        loadPlaylists()
    }

    func delete(_ playlist: Playlist) {
        databaseManager.deletePlaylist(playlist.id)
        loadPlaylists()
    }

    func addSong(_ song: Song, to playlist: Playlist) {
        var updated = playlist
        updated.addSong(song.id)
        save(updated)
    }

    func removeSong(_ song: Song, from playlist: Playlist) {
        var updated = playlist
        updated.removeSong(song.id)
        save(updated)
    }

    func rename(_ playlist: Playlist, to newName: String) {
        var updated = playlist
        updated.name = newName
        updated.dateModified = Date()
        save(updated)
    }

    func reorderPlaylist(_ playlist: Playlist, from source: IndexSet, to destination: Int) {
        var updated = playlist
        updated.moveSong(from: source, to: destination)
        save(updated)
    }

    func toggleFavorite(_ playlist: Playlist) {
        var updated = playlist
        updated.isFavorite.toggle()
        save(updated)
    }

    func duplicate(_ playlist: Playlist) -> Playlist {
        let newPlaylist = Playlist(
            name: "\(playlist.name) (Copy)",
            description: playlist.description,
            songIds: playlist.songIds
        )
        save(newPlaylist)
        return newPlaylist
    }
}
