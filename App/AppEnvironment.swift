import Combine
import Foundation

@MainActor
public final class AppEnvironment: ObservableObject {
    public let libraryStore: any LibraryStore
    public let bookmarkResolver: BookmarkResolving
    public let metadataService: any MetadataService
    public let lyricsProvider: any LyricsProvider
    public let mediaImporter: any MediaImporter
    public let playbackEngine: AVQueuePlaybackEngine
    public let nowPlayingService: NowPlayingService
    public let systemMediaLibraryProvider: any SystemMediaLibraryProviding
    public let backupService: any LibraryBackupProviding
    public let diagnosticsService: any DiagnosticsProviding
    public let theme: SaltTheme

    private var cancellables: Set<AnyCancellable> = []

    public init(
        libraryStore: any LibraryStore,
        bookmarkResolver: BookmarkResolving,
        metadataService: any MetadataService,
        lyricsProvider: any LyricsProvider,
        mediaImporter: any MediaImporter,
        playbackEngine: AVQueuePlaybackEngine,
        nowPlayingService: NowPlayingService,
        systemMediaLibraryProvider: any SystemMediaLibraryProviding,
        backupService: any LibraryBackupProviding,
        diagnosticsService: any DiagnosticsProviding,
        theme: SaltTheme
    ) {
        self.libraryStore = libraryStore
        self.bookmarkResolver = bookmarkResolver
        self.metadataService = metadataService
        self.lyricsProvider = lyricsProvider
        self.mediaImporter = mediaImporter
        self.playbackEngine = playbackEngine
        self.nowPlayingService = nowPlayingService
        self.systemMediaLibraryProvider = systemMediaLibraryProvider
        self.backupService = backupService
        self.diagnosticsService = diagnosticsService
        self.theme = theme

        playbackEngine.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        theme.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    public static func live() -> AppEnvironment {
        do {
            let supportURL = try appSupportDirectory()
            let databaseURL = supportURL.appendingPathComponent("Library.sqlite")
            let lyricsURL = supportURL.appendingPathComponent("Lyrics", isDirectory: true)

            let bookmarkResolver = DefaultBookmarkResolver()
            let libraryStore = try SQLiteLibraryStore(databaseURL: databaseURL)
            let metadataService = AVAssetMetadataService()
            let nowPlayingService = NowPlayingService()
            let audioSessionCoordinator = AudioSessionCoordinator()
            let playbackEngine = AVQueuePlaybackEngine(
                bookmarkResolver: bookmarkResolver,
                audioSessionCoordinator: audioSessionCoordinator,
                nowPlayingService: nowPlayingService
            )
            let lyricsProvider = DefaultLyricsProvider(bookmarkResolver: bookmarkResolver, storageDirectory: lyricsURL)
            let mediaImporter = DocumentMediaImporter(
                libraryStore: libraryStore,
                metadataService: metadataService,
                bookmarkResolver: bookmarkResolver
            )
            let theme = SaltTheme()
            let environment = AppEnvironment(
                libraryStore: libraryStore,
                bookmarkResolver: bookmarkResolver,
                metadataService: metadataService,
                lyricsProvider: lyricsProvider,
                mediaImporter: mediaImporter,
                playbackEngine: playbackEngine,
                nowPlayingService: nowPlayingService,
                systemMediaLibraryProvider: PlaceholderSystemMediaLibraryProvider(),
                backupService: FileLibraryBackupService(databaseURL: databaseURL),
                diagnosticsService: DiagnosticsService(databaseURL: databaseURL),
                theme: theme
            )
            nowPlayingService.attach(to: playbackEngine)
            return environment
        } catch {
            fatalError("Failed to bootstrap SaltMusic environment: \(error)")
        }
    }

    private static func appSupportDirectory() throws -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let url = base.appendingPathComponent("SaltMusic", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
