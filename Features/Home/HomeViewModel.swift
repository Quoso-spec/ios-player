import Foundation
import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recentSongs: [Song] = []
    @Published var allSongs: [Song] = []
    @Published var albums: [Album] = []
    @Published var favoriteSongs: [Song] = []
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0

    private let library = MusicLibrary.shared
    private let recentStore = RecentPlayStore.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        library.$allSongs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] songs in
                self?.allSongs = songs
                self?.favoriteSongs = songs.filter { $0.isFavorite }
            }
            .store(in: &cancellables)

        library.$albums
            .receive(on: DispatchQueue.main)
            .sink { [weak self] albums in
                self?.albums = Array(albums.prefix(6))
            }
            .store(in: &cancellables)

        library.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: &$isScanning)

        library.$scanProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$scanProgress)

        recentStore.$recentSongs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] songs in
                self?.recentSongs = Array(songs.prefix(10))
            }
            .store(in: &cancellables)
    }

    func refreshData() {
        recentStore.loadRecentPlays()
    }

    var hasMusic: Bool {
        !allSongs.isEmpty
    }

    var welcomeMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good Morning"
        } else if hour < 18 {
            return "Good Afternoon"
        } else {
            return "Good Evening"
        }
    }
}
