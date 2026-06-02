import Foundation
import Combine
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var crossfadeEnabled: Bool {
        didSet { settings.crossfadeEnabled = crossfadeEnabled }
    }

    @Published var crossfadeDuration: Double {
        didSet { settings.crossfadeDuration = crossfadeDuration }
    }

    @Published var gaplessPlayback: Bool {
        didSet { settings.gaplessPlaybackEnabled = gaplessPlayback }
    }

    @Published var showAlbumArt: Bool {
        didSet { settings.showAlbumArt = showAlbumArt }
    }

    @Published var showLyrics: Bool {
        didSet { settings.showLyrics = showLyrics }
    }

    @Published var lyricsAutoScroll: Bool {
        didSet { settings.lyricsAutoScroll = lyricsAutoScroll }
    }

    @Published var autoScanOnLaunch: Bool {
        didSet { settings.autoScanOnLaunch = autoScanOnLaunch }
    }

    @Published var songCount: Int = 0
    @Published var albumCount: Int = 0
    @Published var storageUsed: String = "0 MB"

    private let settings = SettingsStore.shared
    private let library = MusicLibrary.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        crossfadeEnabled = settings.crossfadeEnabled
        crossfadeDuration = settings.crossfadeDuration
        gaplessPlayback = settings.gaplessPlaybackEnabled
        showAlbumArt = settings.showAlbumArt
        showLyrics = settings.showLyrics
        lyricsAutoScroll = settings.lyricsAutoScroll
        autoScanOnLaunch = settings.autoScanOnLaunch

        setupBindings()
        calculateStorage()
    }

    private func setupBindings() {
        library.$allSongs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] songs in
                self?.songCount = songs.count
                self?.calculateStorage()
            }
            .store(in: &cancellables)

        library.$albums
            .receive(on: DispatchQueue.main)
            .sink { [weak self] albums in
                self?.albumCount = albums.count
            }
            .store(in: &cancellables)
    }

    private func calculateStorage() {
        let totalBytes = library.allSongs.reduce(0) { $0 + $1.fileSize }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        storageUsed = formatter.string(fromByteCount: totalBytes)
    }

    func resetToDefaults() {
        settings.resetToDefaults()
        crossfadeEnabled = false
        crossfadeDuration = 3.0
        gaplessPlayback = true
        showAlbumArt = true
        showLyrics = true
        lyricsAutoScroll = true
        autoScanOnLaunch = false
    }

    func clearLibrary() {
        // This would clear the library - careful with this
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
