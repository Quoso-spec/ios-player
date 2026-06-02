import Foundation
import Combine

final class RecentPlayStore: ObservableObject {
    static let shared = RecentPlayStore()

    @Published private(set) var recentSongs: [Song] = []
    private let maxRecent = 50

    private let databaseManager = DatabaseManager.shared
    private let musicLibrary = MusicLibrary.shared

    private init() {
        loadRecentPlays()
    }

    func loadRecentPlays() {
        let recentIds = databaseManager.loadRecentPlays(limit: maxRecent)
        recentSongs = recentIds.compactMap { id in
            musicLibrary.allSongs.first { $0.id == id }
        }
    }

    func addPlay(_ song: Song) {
        databaseManager.addRecentPlay(songId: song.id)

        var updated = song
        updated.lastPlayed = Date()
        updated.playCount += 1
        musicLibrary.updateSong(updated)

        loadRecentPlays()
    }

    func clearHistory() {
        recentSongs.removeAll()
    }
}
