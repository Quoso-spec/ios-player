import Foundation
import Combine
import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var albums: [Album] = []
    @Published var artists: [Artist] = []
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    @Published var searchQuery: String = ""
    @Published var searchResults: [Song] = []
    @Published var isSearching: Bool = false
    @Published var sortOrder: SortOrder = .title
    @Published var selectedGrouping: LibraryGrouping = .songs
    @Published var showImportSheet: Bool = false

    private let library = MusicLibrary.shared
    private var cancellables = Set<AnyCancellable>()

    enum LibraryGrouping: String, CaseIterable {
        case songs = "Songs"
        case albums = "Albums"
        case artists = "Artists"

        var icon: String {
            switch self {
            case .songs: return "music.note"
            case .albums: return "square.stack"
            case .artists: return "person"
            }
        }
    }

    init() {
        setupBindings()
    }

    private func setupBindings() {
        library.$allSongs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] songs in
                self?.updateSongs(songs)
            }
            .store(in: &cancellables)

        library.$albums
            .receive(on: DispatchQueue.main)
            .assign(to: &$albums)

        library.$artists
            .receive(on: DispatchQueue.main)
            .assign(to: &$artists)

        library.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: &$isScanning)

        library.$scanProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$scanProgress)

        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.performSearch(query)
            }
            .store(in: &cancellables)
    }

    private func updateSongs(_ allSongs: [Song]) {
        switch sortOrder {
        case .title:
            songs = allSongs.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .artist:
            songs = allSongs.sorted { $0.artist.localizedCaseInsensitiveCompare($1.artist) == .orderedAscending }
        case .album:
            songs = allSongs.sorted { $0.album.localizedCaseInsensitiveCompare($1.album) == .orderedAscending }
        case .dateAdded:
            songs = allSongs.sorted { $0.dateAdded > $1.dateAdded }
        case .duration:
            songs = allSongs.sorted { $0.duration > $1.duration }
        }
    }

    func setSortOrder(_ order: SortOrder) {
        sortOrder = order
        updateSongs(songs)
    }

    func performSearch(_ query: String) {
        isSearching = !query.isEmpty
        if query.isEmpty {
            searchResults = []
        } else {
            searchResults = library.search(query: query)
        }
    }

    func scanDirectory(_ url: URL) {
        Task {
            await library.scanDirectory(url)
        }
    }

    func songs(for album: Album) -> [Song] {
        library.songs(for: album)
    }

    func songs(for artist: Artist) -> [Song] {
        library.songs(for: artist)
    }

    var displayedSongs: [Song] {
        isSearching ? searchResults : songs
    }

    var totalDuration: String {
        let total = displayedSongs.reduce(0) { $0 + $1.duration }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60

        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }

    var songCount: Int {
        displayedSongs.count
    }

    var albumCount: Int {
        albums.count
    }

    var artistCount: Int {
        artists.count
    }

    func toggleFavorite(_ song: Song) {
        var updated = song
        updated.isFavorite.toggle()
        library.updateSong(updated)
    }
}
