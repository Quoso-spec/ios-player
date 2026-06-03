import Foundation
import Combine

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let defaults = UserDefaults.standard

    @Published var crossfadeEnabled: Bool {
        didSet { defaults.set(crossfadeEnabled, forKey: Keys.crossfadeEnabled) }
    }

    @Published var crossfadeDuration: Double {
        didSet { defaults.set(crossfadeDuration, forKey: Keys.crossfadeDuration) }
    }

    @Published var gaplessPlaybackEnabled: Bool {
        didSet { defaults.set(gaplessPlaybackEnabled, forKey: Keys.gaplessPlayback) }
    }

    @Published var equalizerEnabled: Bool {
        didSet { defaults.set(equalizerEnabled, forKey: Keys.equalizerEnabled) }
    }

    @Published var selectedEQPreset: String {
        didSet { defaults.set(selectedEQPreset, forKey: Keys.eqPreset) }
    }

    @Published var volume: Float {
        didSet { defaults.set(volume, forKey: Keys.volume) }
    }

    @Published var repeatMode: Int {
        didSet { defaults.set(repeatMode, forKey: Keys.repeatMode) }
    }

    @Published var shuffleMode: Bool {
        didSet { defaults.set(shuffleMode, forKey: Keys.shuffleMode) }
    }

    @Published var showAlbumArt: Bool {
        didSet { defaults.set(showAlbumArt, forKey: Keys.showAlbumArt) }
    }

    @Published var showLyrics: Bool {
        didSet { defaults.set(showLyrics, forKey: Keys.showLyrics) }
    }

    @Published var lyricsAutoScroll: Bool {
        didSet { defaults.set(lyricsAutoScroll, forKey: Keys.lyricsAutoScroll) }
    }

    @Published var librarySortOrder: String {
        didSet { defaults.set(librarySortOrder, forKey: Keys.sortOrder) }
    }

    @Published var libraryGroupBy: String {
        didSet { defaults.set(libraryGroupBy, forKey: Keys.groupBy) }
    }

    @Published var autoScanOnLaunch: Bool {
        didSet { defaults.set(autoScanOnLaunch, forKey: Keys.autoScan) }
    }

    @Published var authorizedFolderBookmarks: [Data] {
        didSet { defaults.set(authorizedFolderBookmarks, forKey: Keys.folderBookmarks) }
    }

    private struct Keys {
        static let crossfadeEnabled = "crossfadeEnabled"
        static let crossfadeDuration = "crossfadeDuration"
        static let gaplessPlayback = "gaplessPlayback"
        static let equalizerEnabled = "equalizerEnabled"
        static let eqPreset = "eqPreset"
        static let volume = "volume"
        static let repeatMode = "repeatMode"
        static let shuffleMode = "shuffleMode"
        static let showAlbumArt = "showAlbumArt"
        static let showLyrics = "showLyrics"
        static let lyricsAutoScroll = "lyricsAutoScroll"
        static let sortOrder = "librarySortOrder"
        static let groupBy = "libraryGroupBy"
        static let autoScan = "autoScanOnLaunch"
        static let folderBookmarks = "authorizedFolderBookmarks"
    }

    private init() {
        gaplessPlaybackEnabled = defaults.object(forKey: Keys.gaplessPlayback) == nil ? true : defaults.bool(forKey: Keys.gaplessPlayback)
        equalizerEnabled = defaults.object(forKey: Keys.equalizerEnabled) == nil ? false : defaults.bool(forKey: Keys.equalizerEnabled)
        selectedEQPreset = defaults.string(forKey: Keys.eqPreset) ?? "Flat"
        volume = defaults.object(forKey: Keys.volume) == nil ? 1.0 : defaults.float(forKey: Keys.volume)
        repeatMode = defaults.object(forKey: Keys.repeatMode) == nil ? 0 : defaults.integer(forKey: Keys.repeatMode)
        shuffleMode = defaults.bool(forKey: Keys.shuffleMode)

        showAlbumArt = defaults.object(forKey: Keys.showAlbumArt) == nil ? true : defaults.bool(forKey: Keys.showAlbumArt)
        showLyrics = defaults.object(forKey: Keys.showLyrics) == nil ? true : defaults.bool(forKey: Keys.showLyrics)
        lyricsAutoScroll = defaults.object(forKey: Keys.lyricsAutoScroll) == nil ? true : defaults.bool(forKey: Keys.lyricsAutoScroll)

        librarySortOrder = defaults.string(forKey: Keys.sortOrder) ?? "title"
        libraryGroupBy = defaults.string(forKey: Keys.groupBy) ?? "song"
        autoScanOnLaunch = defaults.object(forKey: Keys.autoScan) == nil ? true : defaults.bool(forKey: Keys.autoScan)

        authorizedFolderBookmarks = defaults.array(forKey: Keys.folderBookmarks) as? [Data] ?? []

        crossfadeEnabled = defaults.bool(forKey: Keys.crossfadeEnabled)
        crossfadeDuration = defaults.double(forKey: Keys.crossfadeDuration)
        if crossfadeDuration == 0 { crossfadeDuration = 3.0 }
    }

    func resetToDefaults() {
        crossfadeEnabled = false
        crossfadeDuration = 3.0
        gaplessPlaybackEnabled = true
        equalizerEnabled = false
        selectedEQPreset = "Flat"
        volume = 1.0
        repeatMode = 0
        shuffleMode = false
        showAlbumArt = true
        showLyrics = true
        lyricsAutoScroll = true
        librarySortOrder = "title"
        libraryGroupBy = "song"
        autoScanOnLaunch = false
    }
}
