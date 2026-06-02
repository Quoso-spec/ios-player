import Foundation
import SQLite

final class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: Connection?
    private let dbPath: String

    private let songsTable = Table("songs")
    private let albumsTable = Table("albums")
    private let artistsTable = Table("artists")
    private let playlistsTable = Table("playlists")
    private let playlistSongsTable = Table("playlist_songs")
    private let recentPlaysTable = Table("recent_plays")

    private let id = SQLite.Expression<String>("id")
    private let title = SQLite.Expression<String>("title")
    private let artist = SQLite.Expression<String>("artist")
    private let album = SQLite.Expression<String>("album")
    private let albumArtist = SQLite.Expression<String>("album_artist")
    private let duration = SQLite.Expression<Double>("duration")
    private let trackNumber = SQLite.Expression<Int>("track_number")
    private let discNumber = SQLite.Expression<Int>("disc_number")
    private let year = SQLite.Expression<Int>("year")
    private let genre = SQLite.Expression<String>("genre")
    private let filePath = SQLite.Expression<String>("file_path")
    private let fileSize = SQLite.Expression<Int64>("file_size")
    private let artworkData = SQLite.Expression<Data?>("artwork_data")
    private let dateAdded = SQLite.Expression<Date>("date_added")
    private let lastPlayed = SQLite.Expression<Date?>("last_played")
    private let playCount = SQLite.Expression<Int>("play_count")
    private let isFavorite = SQLite.Expression<Bool>("is_favorite")

    private let name = SQLite.Expression<String>("name")
    private let description = SQLite.Expression<String>("description")
    private let songIds = SQLite.Expression<String>("song_ids")
    private let dateCreated = SQLite.Expression<Date>("date_created")
    private let dateModified = SQLite.Expression<Date>("date_modified")
    private let songId = SQLite.Expression<String>("song_id")
    private let playlistId = SQLite.Expression<String>("playlist_id")
    private let songOrder = SQLite.Expression<Int>("song_order")

    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        dbPath = documentsPath.appendingPathComponent("saltplayer.sqlite3").path
    }

    func initializeDatabase() {
        do {
            db = try Connection(dbPath)
            try createTables()
        } catch {
            print("Failed to initialize database: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(songsTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(artist)
            t.column(album)
            t.column(albumArtist)
            t.column(duration)
            t.column(trackNumber)
            t.column(discNumber)
            t.column(year)
            t.column(genre)
            t.column(filePath)
            t.column(fileSize)
            t.column(artworkData)
            t.column(dateAdded)
            t.column(lastPlayed)
            t.column(playCount)
            t.column(isFavorite)
        })

        try db?.run(albumsTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(artist)
            t.column(year)
            t.column(songIds)
            t.column(artworkData)
            t.column(dateAdded)
        })

        try db?.run(artistsTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(songIds)
            t.column(artworkData)
        })

        try db?.run(playlistsTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(description)
            t.column(dateCreated)
            t.column(dateModified)
            t.column(isFavorite)
        })

        try db?.run(playlistSongsTable.create(ifNotExists: true) { t in
            t.column(playlistId)
            t.column(songId)
            t.column(songOrder, primaryKey: true)
        })

        try db?.run(recentPlaysTable.create(ifNotExists: true) { t in
            t.column(songId, primaryKey: true)
            t.column(dateAdded)
        })
    }

    func saveSongs(_ songs: [Song]) {
        guard let db = db else { return }

        do {
            try db.transaction {
                try db.run(songsTable.delete())

                for song in songs {
                    try db.run(songsTable.insert(or: .replace,
                        id <- song.id,
                        title <- song.title,
                        artist <- song.artist,
                        album <- song.album,
                        albumArtist <- song.albumArtist,
                        duration <- song.duration,
                        trackNumber <- song.trackNumber,
                        discNumber <- song.discNumber,
                        year <- song.year,
                        genre <- song.genre,
                        filePath <- song.filePath,
                        fileSize <- song.fileSize,
                        artworkData <- song.artworkData,
                        dateAdded <- song.dateAdded,
                        lastPlayed <- song.lastPlayed,
                        playCount <- song.playCount,
                        isFavorite <- song.isFavorite
                    ))
                }
            }
        } catch {
            print("Failed to save songs: \(error)")
        }
    }

    func loadSongs() -> [Song]? {
        guard let db = db else { return nil }

        var songs: [Song] = []

        do {
            for row in try db.prepare(songsTable) {
                let song = Song(
                    id: row[id],
                    title: row[title],
                    artist: row[artist],
                    album: row[album],
                    albumArtist: row[albumArtist],
                    duration: row[duration],
                    trackNumber: row[trackNumber],
                    discNumber: row[discNumber],
                    year: row[year],
                    genre: row[genre],
                    filePath: row[filePath],
                    fileSize: row[fileSize],
                    artworkData: row[artworkData],
                    dateAdded: row[dateAdded],
                    lastPlayed: row[lastPlayed],
                    playCount: row[playCount],
                    isFavorite: row[isFavorite]
                )
                songs.append(song)
            }
        } catch {
            print("Failed to load songs: \(error)")
        }

        return songs
    }

    func saveAlbums(_ albums: [Album]) {
        guard let db = db else { return }

        do {
            try db.transaction {
                try db.run(albumsTable.delete())

                for album in albums {
                    let songIdsString = album.songIds.joined(separator: ",")
                    try db.run(albumsTable.insert(or: .replace,
                        id <- album.id,
                        name <- album.name,
                        artist <- album.artist,
                        year <- album.year,
                        songIds <- songIdsString,
                        artworkData <- album.artworkData,
                        dateAdded <- album.dateAdded
                    ))
                }
            }
        } catch {
            print("Failed to save albums: \(error)")
        }
    }

    func loadAlbums() -> [Album]? {
        guard let db = db else { return nil }

        var albums: [Album] = []

        do {
            for row in try db.prepare(albumsTable) {
                let songIdsString = row[songIds]
                let songIdArray = songIdsString.isEmpty ? [] : songIdsString.components(separatedBy: ",")

                let album = Album(
                    id: row[id],
                    name: row[name],
                    artist: row[artist],
                    year: row[year],
                    songIds: songIdArray,
                    artworkData: row[artworkData],
                    dateAdded: row[dateAdded]
                )
                albums.append(album)
            }
        } catch {
            print("Failed to load albums: \(error)")
        }

        return albums
    }

    func saveArtists(_ artists: [Artist]) {
        guard let db = db else { return }

        do {
            try db.transaction {
                try db.run(artistsTable.delete())

                for artist in artists {
                    let songIdsString = artist.songIds.joined(separator: ",")
                    let albumIdsString = artist.albumIds.joined(separator: ",")
                    try db.run(artistsTable.insert(or: .replace,
                        id <- artist.id,
                        name <- artist.name,
                        songIds <- "\(albumIdsString)|\(songIdsString)",
                        artworkData <- artist.artworkData
                    ))
                }
            }
        } catch {
            print("Failed to save artists: \(error)")
        }
    }

    func loadArtists() -> [Artist]? {
        guard let db = db else { return nil }

        var artists: [Artist] = []

        do {
            for row in try db.prepare(artistsTable) {
                let combined = row[songIds]
                let parts = combined.components(separatedBy: "|")
                let albumIds = parts.first?.components(separatedBy: ",").filter { !$0.isEmpty } ?? []
                let songIdsArray = parts.count > 1 ? parts[1].components(separatedBy: ",").filter { !$0.isEmpty } : []

                let artist = Artist(
                    id: row[id],
                    name: row[name],
                    albumIds: albumIds,
                    songIds: songIdsArray,
                    artworkData: row[artworkData]
                )
                artists.append(artist)
            }
        } catch {
            print("Failed to load artists: \(error)")
        }

        return artists
    }

    func savePlaylist(_ playlist: Playlist) {
        guard let db = db else { return }

        do {
            try db.run(playlistsTable.insert(or: .replace,
                id <- playlist.id,
                name <- playlist.name,
                description <- playlist.description,
                dateCreated <- playlist.dateCreated,
                dateModified <- playlist.dateModified,
                isFavorite <- playlist.isFavorite
            ))

            try db.run(playlistSongsTable.filter(playlistId == playlist.id).delete())

            for (index, songIdValue) in playlist.songIds.enumerated() {
                try db.run(playlistSongsTable.insert(
                    playlistId <- playlist.id,
                    songId <- songIdValue,
                    songOrder <- index
                ))
            }
        } catch {
            print("Failed to save playlist: \(error)")
        }
    }

    func loadPlaylists() -> [Playlist] {
        guard let db = db else { return [] }

        var playlists: [Playlist] = []

        do {
            for row in try db.prepare(playlistsTable) {
                let playlistSongIds = loadPlaylistSongIds(playlistId: row[id])

                let playlist = Playlist(
                    id: row[id],
                    name: row[name],
                    description: row[description],
                    songIds: playlistSongIds,
                    artworkData: nil,
                    dateCreated: row[dateCreated],
                    dateModified: row[dateModified],
                    isFavorite: row[isFavorite]
                )
                playlists.append(playlist)
            }
        } catch {
            print("Failed to load playlists: \(error)")
        }

        return playlists
    }

    private func loadPlaylistSongIds(playlistId pid: String) -> [String] {
        guard let db = db else { return [] }

        var songIds: [String] = []

        do {
            let query = playlistSongsTable.filter(playlistId == pid).order(songOrder)
            for row in try db.prepare(query) {
                songIds.append(row[songId])
            }
        } catch {
            print("Failed to load playlist song ids: \(error)")
        }

        return songIds
    }

    func deletePlaylist(_ playlistIdValue: String) {
        guard let db = db else { return }

        do {
            try db.run(playlistSongsTable.filter(playlistId == playlistIdValue).delete())
            try db.run(playlistsTable.filter(id == playlistIdValue).delete())
        } catch {
            print("Failed to delete playlist: \(error)")
        }
    }

    func addRecentPlay(songId sid: String) {
        guard let db = db else { return }

        do {
            try db.run(recentPlaysTable.insert(or: .replace,
                songId <- sid,
                dateAdded <- Date()
            ))
        } catch {
            print("Failed to add recent play: \(error)")
        }
    }

    func loadRecentPlays(limit: Int = 50) -> [String] {
        guard let db = db else { return [] }

        var songIds: [String] = []

        do {
            let query = recentPlaysTable.order(dateAdded.desc).limit(limit)
            for row in try db.prepare(query) {
                songIds.append(row[songId])
            }
        } catch {
            print("Failed to load recent plays: \(error)")
        }

        return songIds
    }

    func updateSong(_ song: Song) {
        guard let db = db else { return }

        do {
            let target = songsTable.filter(id == song.id)
            try db.run(target.update(
                title <- song.title,
                artist <- song.artist,
                album <- song.album,
                albumArtist <- song.albumArtist,
                duration <- song.duration,
                trackNumber <- song.trackNumber,
                discNumber <- song.discNumber,
                year <- song.year,
                genre <- song.genre,
                filePath <- song.filePath,
                fileSize <- song.fileSize,
                artworkData <- song.artworkData,
                dateAdded <- song.dateAdded,
                lastPlayed <- song.lastPlayed,
                playCount <- song.playCount,
                isFavorite <- song.isFavorite
            ))
        } catch {
            print("Failed to update song: \(error)")
        }
    }
}
