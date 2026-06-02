import Foundation

public protocol LibraryStore {
    var databaseURL: URL { get }

    func migrate() async throws
    func upsertTrack(_ track: Track) async throws
    func track(id: UUID) async throws -> Track?
    func tracks(sort: TrackSort) async throws -> [Track]
    func searchTracks(query: String) async throws -> [Track]
    func deleteTrack(id: UUID) async throws
    func setFavorite(trackID: UUID, isFavorite: Bool) async throws
    func markTrackMissing(id: UUID, isMissing: Bool) async throws
    func recordPlayback(trackID: UUID, at date: Date) async throws
    func playlists() async throws -> [Playlist]
    func savePlaylist(_ playlist: Playlist) async throws
    func libraryStatistics() async throws -> LibraryStatistics
}

