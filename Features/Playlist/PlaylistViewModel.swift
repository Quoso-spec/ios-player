import Foundation
import Combine
import SwiftUI

@MainActor
final class PlaylistViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var selectedPlaylist: Playlist?
    @Published var showCreateSheet: Bool = false
    @Published var newPlaylistName: String = ""
    @Published var newPlaylistDescription: String = ""

    private let store = PlaylistStore.shared
    private let library = MusicLibrary.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        store.$playlists
            .receive(on: DispatchQueue.main)
            .assign(to: &$playlists)
    }

    func createPlaylist() {
        guard !newPlaylistName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let _ = store.createPlaylist(name: newPlaylistName, description: newPlaylistDescription)
        newPlaylistName = ""
        newPlaylistDescription = ""
        showCreateSheet = false
    }

    func deletePlaylist(_ playlist: Playlist) {
        store.delete(playlist)
    }

    func renamePlaylist(_ playlist: Playlist, to newName: String) {
        store.rename(playlist, to: newName)
    }

    func addSong(_ song: Song, to playlist: Playlist) {
        store.addSong(song, to: playlist)
    }

    func removeSong(_ song: Song, from playlist: Playlist) {
        store.removeSong(song, from: playlist)
    }

    func reorderSongs(in playlist: Playlist, from source: IndexSet, to destination: Int) {
        store.reorderPlaylist(playlist, from: source, to: destination)
    }

    func toggleFavorite(_ playlist: Playlist) {
        store.toggleFavorite(playlist)
    }

    func duplicatePlaylist(_ playlist: Playlist) {
        let _ = store.duplicate(playlist)
    }

    func songs(for playlist: Playlist) -> [Song] {
        playlist.songIds.compactMap { id in
            library.allSongs.first { $0.id == id }
        }
    }

    var totalDuration(for playlist: Playlist) -> String {
        let songs = songs(for: playlist)
        let total = songs.reduce(0) { $0 + $1.duration }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60

        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }

    var favoritePlaylists: [Playlist] {
        playlists.filter { $0.isFavorite }
    }

    var recentPlaylists: [Playlist] {
        playlists.sorted { $0.dateModified > $1.dateModified }
    }
}
