import Foundation

public final class SQLiteLibraryStore: LibraryStore {
    public let databaseURL: URL

    private let sqlite: SQLiteStore
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(databaseURL: URL) throws {
        self.databaseURL = databaseURL
        self.sqlite = try SQLiteStore(url: databaseURL)
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        try migrateSchema()
    }

    public func migrate() async throws {
        try migrateSchema()
    }

    private func migrateSchema() throws {
        try sqlite.execute("""
        CREATE TABLE IF NOT EXISTS tracks (
            id TEXT PRIMARY KEY NOT NULL,
            source_bookmark BLOB NOT NULL,
            file_name TEXT NOT NULL,
            path_hint TEXT,
            title TEXT,
            artist TEXT,
            album TEXT,
            album_artist TEXT,
            duration REAL NOT NULL DEFAULT 0,
            format TEXT,
            bitrate INTEGER,
            sample_rate INTEGER,
            artwork_id TEXT,
            lyrics_id TEXT,
            metadata_override_json TEXT,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            play_count INTEGER NOT NULL DEFAULT 0,
            added_at REAL NOT NULL,
            updated_at REAL NOT NULL,
            last_played_at REAL,
            is_missing INTEGER NOT NULL DEFAULT 0
        )
        """)

        try sqlite.execute("""
        CREATE TABLE IF NOT EXISTS playlists (
            id TEXT PRIMARY KEY NOT NULL,
            name TEXT NOT NULL,
            created_at REAL NOT NULL,
            updated_at REAL NOT NULL
        )
        """)

        try sqlite.execute("""
        CREATE TABLE IF NOT EXISTS playlist_items (
            playlist_id TEXT NOT NULL,
            track_id TEXT NOT NULL,
            position INTEGER NOT NULL,
            PRIMARY KEY (playlist_id, track_id),
            FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
            FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
        )
        """)

        try sqlite.execute("""
        CREATE TABLE IF NOT EXISTS playback_history (
            id TEXT PRIMARY KEY NOT NULL,
            track_id TEXT NOT NULL,
            played_at REAL NOT NULL,
            FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
        )
        """)
    }

    public func upsertTrack(_ track: Track) async throws {
        let overrideJSON = try encodeOverride(track.metadataOverride)
        try sqlite.run("""
        INSERT INTO tracks (
            id, source_bookmark, file_name, path_hint, title, artist, album, album_artist,
            duration, format, bitrate, sample_rate, artwork_id, lyrics_id, metadata_override_json,
            is_favorite, play_count, added_at, updated_at, last_played_at, is_missing
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            source_bookmark = excluded.source_bookmark,
            file_name = excluded.file_name,
            path_hint = excluded.path_hint,
            title = excluded.title,
            artist = excluded.artist,
            album = excluded.album,
            album_artist = excluded.album_artist,
            duration = excluded.duration,
            format = excluded.format,
            bitrate = excluded.bitrate,
            sample_rate = excluded.sample_rate,
            artwork_id = excluded.artwork_id,
            lyrics_id = excluded.lyrics_id,
            metadata_override_json = excluded.metadata_override_json,
            is_favorite = excluded.is_favorite,
            play_count = excluded.play_count,
            updated_at = excluded.updated_at,
            last_played_at = excluded.last_played_at,
            is_missing = excluded.is_missing
        """) { statement in
            try bind(track, overrideJSON: overrideJSON, statement: statement)
        }
    }

    public func track(id: UUID) async throws -> Track? {
        let matches = try sqlite.query("SELECT * FROM tracks WHERE id = ? LIMIT 1") { statement in
            try sqlite.bind(id.uuidString, at: 1, in: statement)
        } map: { statement in
            try mapTrack(statement)
        }
        return matches.first
    }

    public func tracks(sort: TrackSort = .title) async throws -> [Track] {
        let orderBy: String
        switch sort {
        case .title:
            orderBy = "COALESCE(title, file_name) COLLATE NOCASE ASC"
        case .artist:
            orderBy = "COALESCE(artist, '') COLLATE NOCASE ASC, COALESCE(title, file_name) COLLATE NOCASE ASC"
        case .album:
            orderBy = "COALESCE(album, '') COLLATE NOCASE ASC, COALESCE(title, file_name) COLLATE NOCASE ASC"
        case .recentlyAdded:
            orderBy = "added_at DESC"
        case .recentlyPlayed:
            orderBy = "COALESCE(last_played_at, 0) DESC"
        }
        return try sqlite.query("SELECT * FROM tracks ORDER BY \(orderBy)", map: { statement in
            try mapTrack(statement)
        })
    }

    public func searchTracks(query: String) async throws -> [Track] {
        let pattern = "%\(query)%"
        return try sqlite.query("""
        SELECT * FROM tracks
        WHERE title LIKE ? OR artist LIKE ? OR album LIKE ? OR file_name LIKE ?
        ORDER BY COALESCE(title, file_name) COLLATE NOCASE ASC
        """) { statement in
            try sqlite.bind(pattern, at: 1, in: statement)
            try sqlite.bind(pattern, at: 2, in: statement)
            try sqlite.bind(pattern, at: 3, in: statement)
            try sqlite.bind(pattern, at: 4, in: statement)
        } map: { statement in
            try mapTrack(statement)
        }
    }

    public func deleteTrack(id: UUID) async throws {
        try sqlite.run("DELETE FROM tracks WHERE id = ?") { statement in
            try sqlite.bind(id.uuidString, at: 1, in: statement)
        }
    }

    public func setFavorite(trackID: UUID, isFavorite: Bool) async throws {
        try sqlite.run("UPDATE tracks SET is_favorite = ?, updated_at = ? WHERE id = ?") { statement in
            try sqlite.bind(isFavorite ? 1 : 0, at: 1, in: statement)
            try sqlite.bind(Date().timeIntervalSince1970, at: 2, in: statement)
            try sqlite.bind(trackID.uuidString, at: 3, in: statement)
        }
    }

    public func markTrackMissing(id: UUID, isMissing: Bool) async throws {
        try sqlite.run("UPDATE tracks SET is_missing = ?, updated_at = ? WHERE id = ?") { statement in
            try sqlite.bind(isMissing ? 1 : 0, at: 1, in: statement)
            try sqlite.bind(Date().timeIntervalSince1970, at: 2, in: statement)
            try sqlite.bind(id.uuidString, at: 3, in: statement)
        }
    }

    public func recordPlayback(trackID: UUID, at date: Date = Date()) async throws {
        try sqlite.run("""
        INSERT INTO playback_history (id, track_id, played_at) VALUES (?, ?, ?)
        """) { statement in
            try sqlite.bind(UUID().uuidString, at: 1, in: statement)
            try sqlite.bind(trackID.uuidString, at: 2, in: statement)
            try sqlite.bind(date.timeIntervalSince1970, at: 3, in: statement)
        }
        try sqlite.run("""
        UPDATE tracks SET play_count = play_count + 1, last_played_at = ?, updated_at = ? WHERE id = ?
        """) { statement in
            try sqlite.bind(date.timeIntervalSince1970, at: 1, in: statement)
            try sqlite.bind(date.timeIntervalSince1970, at: 2, in: statement)
            try sqlite.bind(trackID.uuidString, at: 3, in: statement)
        }
    }

    public func playlists() async throws -> [Playlist] {
        let rows = try sqlite.query("""
        SELECT p.id, p.name, p.created_at, p.updated_at, GROUP_CONCAT(pi.track_id)
        FROM playlists p
        LEFT JOIN playlist_items pi ON p.id = pi.playlist_id
        GROUP BY p.id
        ORDER BY p.updated_at DESC
        """, map: { statement -> Playlist in
            let id = UUID(uuidString: sqlite.textColumn(statement, index: 0) ?? "") ?? UUID()
            let name = sqlite.textColumn(statement, index: 1) ?? "Untitled"
            let createdAt = Date(timeIntervalSince1970: sqlite.doubleColumn(statement, index: 2))
            let updatedAt = Date(timeIntervalSince1970: sqlite.doubleColumn(statement, index: 3))
            let ids = sqlite.textColumn(statement, index: 4)?
                .split(separator: ",")
                .compactMap { UUID(uuidString: String($0)) } ?? []
            return Playlist(id: id, name: name, createdAt: createdAt, updatedAt: updatedAt, trackIDs: ids)
        })
        return rows
    }

    public func savePlaylist(_ playlist: Playlist) async throws {
        try sqlite.run("""
        INSERT INTO playlists (id, name, created_at, updated_at)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET name = excluded.name, updated_at = excluded.updated_at
        """) { statement in
            try sqlite.bind(playlist.id.uuidString, at: 1, in: statement)
            try sqlite.bind(playlist.name, at: 2, in: statement)
            try sqlite.bind(playlist.createdAt.timeIntervalSince1970, at: 3, in: statement)
            try sqlite.bind(playlist.updatedAt.timeIntervalSince1970, at: 4, in: statement)
        }
        try sqlite.run("DELETE FROM playlist_items WHERE playlist_id = ?") { statement in
            try sqlite.bind(playlist.id.uuidString, at: 1, in: statement)
        }
        for (position, trackID) in playlist.trackIDs.enumerated() {
            try sqlite.run("""
            INSERT INTO playlist_items (playlist_id, track_id, position) VALUES (?, ?, ?)
            """) { statement in
                try sqlite.bind(playlist.id.uuidString, at: 1, in: statement)
                try sqlite.bind(trackID.uuidString, at: 2, in: statement)
                try sqlite.bind(position, at: 3, in: statement)
            }
        }
    }

    public func libraryStatistics() async throws -> LibraryStatistics {
        try sqlite.query("""
        SELECT COUNT(*), COALESCE(SUM(is_favorite), 0), COALESCE(SUM(duration), 0), (SELECT COUNT(*) FROM playlists)
        FROM tracks
        """, map: { statement -> LibraryStatistics in
            LibraryStatistics(
                trackCount: sqlite.intColumn(statement, index: 0),
                favoriteCount: sqlite.intColumn(statement, index: 1),
                playlistCount: sqlite.intColumn(statement, index: 3),
                totalDuration: sqlite.doubleColumn(statement, index: 2)
            )
        }).first ?? LibraryStatistics()
    }

    private func bind(_ track: Track, overrideJSON: String?, statement: OpaquePointer?) throws {
        try sqlite.bind(track.id.uuidString, at: 1, in: statement)
        try sqlite.bind(track.sourceURLBookmark, at: 2, in: statement)
        try sqlite.bind(track.fileName, at: 3, in: statement)
        try sqlite.bind(track.originalFilePathHint, at: 4, in: statement)
        try sqlite.bind(track.title, at: 5, in: statement)
        try sqlite.bind(track.artist, at: 6, in: statement)
        try sqlite.bind(track.album, at: 7, in: statement)
        try sqlite.bind(track.albumArtist, at: 8, in: statement)
        try sqlite.bind(track.duration, at: 9, in: statement)
        try sqlite.bind(track.format, at: 10, in: statement)
        try sqlite.bind(track.bitrate, at: 11, in: statement)
        try sqlite.bind(track.sampleRate, at: 12, in: statement)
        try sqlite.bind(track.artworkID, at: 13, in: statement)
        try sqlite.bind(track.lyricsID, at: 14, in: statement)
        try sqlite.bind(overrideJSON, at: 15, in: statement)
        try sqlite.bind(track.isFavorite ? 1 : 0, at: 16, in: statement)
        try sqlite.bind(track.playCount, at: 17, in: statement)
        try sqlite.bind(track.addedAt.timeIntervalSince1970, at: 18, in: statement)
        try sqlite.bind(track.updatedAt.timeIntervalSince1970, at: 19, in: statement)
        try sqlite.bind(track.lastPlayedAt?.timeIntervalSince1970, at: 20, in: statement)
        try sqlite.bind(track.isMissing ? 1 : 0, at: 21, in: statement)
    }

    private func mapTrack(_ statement: OpaquePointer?) throws -> Track {
        let id = UUID(uuidString: sqlite.textColumn(statement, index: 0) ?? "") ?? UUID()
        let overrideJSON = sqlite.textColumn(statement, index: 14)
        let metadataOverride = try decodeOverride(overrideJSON)
        let lastPlayedValue = sqlite.isNullColumn(statement, index: 19) ? nil : sqlite.doubleColumn(statement, index: 19)
        return Track(
            id: id,
            sourceURLBookmark: sqlite.dataColumn(statement, index: 1) ?? Data(),
            fileName: sqlite.textColumn(statement, index: 2) ?? "Unknown File",
            originalFilePathHint: sqlite.textColumn(statement, index: 3),
            title: sqlite.textColumn(statement, index: 4),
            artist: sqlite.textColumn(statement, index: 5),
            album: sqlite.textColumn(statement, index: 6),
            albumArtist: sqlite.textColumn(statement, index: 7),
            duration: sqlite.doubleColumn(statement, index: 8),
            format: sqlite.textColumn(statement, index: 9),
            bitrate: optionalInt(statement, index: 10),
            sampleRate: optionalInt(statement, index: 11),
            artworkID: sqlite.textColumn(statement, index: 12),
            lyricsID: sqlite.textColumn(statement, index: 13),
            metadataOverride: metadataOverride,
            isFavorite: sqlite.intColumn(statement, index: 15) == 1,
            playCount: sqlite.intColumn(statement, index: 16),
            addedAt: Date(timeIntervalSince1970: sqlite.doubleColumn(statement, index: 17)),
            updatedAt: Date(timeIntervalSince1970: sqlite.doubleColumn(statement, index: 18)),
            lastPlayedAt: lastPlayedValue.map { Date(timeIntervalSince1970: $0) },
            isMissing: sqlite.intColumn(statement, index: 20) == 1
        )
    }

    private func optionalInt(_ statement: OpaquePointer?, index: Int32) -> Int? {
        sqlite.isNullColumn(statement, index: index) ? nil : sqlite.intColumn(statement, index: index)
    }

    private func encodeOverride(_ override: MetadataOverride?) throws -> String? {
        guard let override else {
            return nil
        }
        let data = try encoder.encode(override)
        return String(data: data, encoding: .utf8)
    }

    private func decodeOverride(_ json: String?) throws -> MetadataOverride? {
        guard let json, let data = json.data(using: .utf8) else {
            return nil
        }
        return try decoder.decode(MetadataOverride.self, from: data)
    }
}
