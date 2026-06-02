import Foundation
import Combine

final class MusicLibrary: ObservableObject {
    static let shared = MusicLibrary()

    @Published private(set) var allSongs: [Song] = []
    @Published private(set) var albums: [Album] = []
    @Published private(set) var artists: [Artist] = []
    @Published private(set) var isScanning: Bool = false
    @Published private(set) var scanProgress: Double = 0.0
    @Published var authorizedFolders: [URL] = []

    private let metadataReader = MetadataReader.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadFromDatabase()
    }

    func scanDirectory(_ url: URL) async {
        await MainActor.run {
            isScanning = true
            scanProgress = 0
        }

        let files = await MediaScanner.shared.scanForAudioFiles(in: url)
        let total = files.count

        var scannedSongs: [Song] = []

        for (index, fileURL) in files.enumerated() {
            let song = await metadataReader.readMetadata(from: fileURL)
            scannedSongs.append(song)

            await MainActor.run {
                scanProgress = Double(index + 1) / Double(total)
            }

            if index % 10 == 0 {
                try? await Task.sleep(nanoseconds: 1_000_000)
            }
        }

        await MainActor.run {
            allSongs = mergeSongs(scannedSongs)
            rebuildAlbums()
            rebuildArtists()
            saveToDatabase()
            isScanning = false
        }
    }

    private func mergeSongs(_ newSongs: [Song]) -> [Song] {
        var existingIds = Set(allSongs.map { $0.id })
        var merged = allSongs

        for song in newSongs {
            if !existingIds.contains(song.id) {
                merged.append(song)
                existingIds.insert(song.id)
            }
        }

        return merged.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    private func rebuildAlbums() {
        var albumDict: [String: [Song]] = [:]

        for song in allSongs {
            let key = "\(song.album)|\(song.albumArtist)"
            if albumDict[key] != nil {
                albumDict[key]?.append(song)
            } else {
                albumDict[key] = [song]
            }
        }

        albums = albumDict.map { (key, songs) -> Album in
            let parts = key.split(separator: "|")
            let albumName = String(parts.first ?? "")
            let artistName = parts.count > 1 ? String(parts[1]) : songs.first?.artist ?? "Unknown Artist"

            let sortedSongs = songs.sorted { song1, song2 in
                if song1.discNumber != song2.discNumber {
                    return song1.discNumber < song2.discNumber
                }
                return song1.trackNumber < song2.trackNumber
            }

            return Album(
                name: albumName,
                artist: artistName,
                year: songs.first?.year ?? 0,
                songIds: sortedSongs.map { $0.id },
                artworkData: songs.first(where: { $0.artworkData != nil })?.artworkData ?? songs.first?.artworkData,
                dateAdded: songs.map { $0.dateAdded }.min() ?? Date()
            )
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func rebuildArtists() {
        var artistDict: [String: [String]] = [:]
        var artistAlbumDict: [String: Set<String>] = [:]

        for album in albums {
            if artistDict[album.artist] != nil {
                artistDict[album.artist]?.append(contentsOf: album.songIds)
                artistAlbumDict[album.artist]?.insert(album.id)
            } else {
                artistDict[album.artist] = album.songIds
                artistAlbumDict[album.artist] = [album.id]
            }
        }

        artists = artistDict.map { (name, songIds) -> Artist in
            Artist(
                name: name,
                albumIds: Array(artistAlbumDict[name] ?? []),
                songIds: songIds
            )
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func search(query: String) -> [Song] {
        guard !query.isEmpty else { return allSongs }
        let lowercased = query.lowercased()
        return allSongs.filter {
            $0.title.lowercased().contains(lowercased) ||
            $0.artist.lowercased().contains(lowercased) ||
            $0.album.lowercased().contains(lowercased)
        }
    }

    func songs(for album: Album) -> [Song] {
        album.songIds.compactMap { id in allSongs.first { $0.id == id } }
    }

    func songs(for artist: Artist) -> [Song] {
        artist.songIds.compactMap { id in allSongs.first { $0.id == id } }
    }

    func album(for song: Song) -> Album? {
        albums.first { $0.songIds.contains(song.id) }
    }

    func artist(for song: Song) -> Artist? {
        artists.first { $0.songIds.contains(song.id) }
    }

    private func saveToDatabase() {
        DatabaseManager.shared.saveSongs(allSongs)
        DatabaseManager.shared.saveAlbums(albums)
        DatabaseManager.shared.saveArtists(artists)
    }

    private func loadFromDatabase() {
        if let songs = DatabaseManager.shared.loadSongs(), !songs.isEmpty {
            allSongs = songs
            rebuildAlbums()
            rebuildArtists()
        }
    }

    func removeSong(_ song: Song) {
        allSongs.removeAll { $0.id == song.id }
        rebuildAlbums()
        rebuildArtists()
        saveToDatabase()
    }

    func removeSongs(at offsets: IndexSet) {
        let idsToRemove = offsets.map { allSongs[$0].id }
        allSongs.removeAll { idsToRemove.contains($0.id) }
        rebuildAlbums()
        rebuildArtists()
        saveToDatabase()
    }

    func updateSong(_ song: Song) {
        if let index = allSongs.firstIndex(where: { $0.id == song.id }) {
            allSongs[index] = song
            saveToDatabase()
        }
    }
}
