import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @EnvironmentObject var libraryViewModel: LibraryViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.hasMusic {
                    mainContent
                } else {
                    emptyState
                }
            }
            .background(SaltColors.background)
            .navigationTitle("Salt Player")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { libraryViewModel.showImportSheet = true }) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(SaltColors.accent)
                    }
                }
            }
            .sheet(isPresented: $libraryViewModel.showImportSheet) {
                DocumentPickerView { url in
                    libraryViewModel.scanDirectory(url)
                }
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: SaltTheme.spacingXL) {
            if !viewModel.recentSongs.isEmpty {
                recentlyPlayedSection
            }

            allSongsSection

            albumsSection

            if !viewModel.favoriteSongs.isEmpty {
                favoritesSection
            }
        }
        .padding(.horizontal, SaltTheme.spacingL)
        .padding(.bottom, SaltTheme.miniPlayerHeight + 20)
    }

    @ViewBuilder
    private var recentlyPlayedSection: some View {
        VStack(alignment: .leading, spacing: SaltTheme.spacingM) {
            SectionHeader(title: "Recently Played")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SaltTheme.spacingM) {
                    ForEach(viewModel.recentSongs) { song in
                        SongRowCompactView(song: song) {
                            playerViewModel.play(song: song, in: viewModel.recentSongs)
                        }
                        .frame(width: 280)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var allSongsSection: some View {
        VStack(alignment: .leading, spacing: SaltTheme.spacingM) {
            SectionHeader(title: "All Songs", subtitle: "\(viewModel.allSongs.count) songs")

            ForEach(Array(viewModel.allSongs.prefix(5))) { song in
                SongRowView(song: song, onTap: {
                    playerViewModel.play(songs: viewModel.allSongs, startingAt: viewModel.allSongs.firstIndex(where: { $0.id == song.id }) ?? 0)
                })
                Divider()
                    .background(SaltColors.divider)
            }

            if viewModel.allSongs.count > 5 {
                NavigationLink(destination: LibraryView()) {
                    Text("View All \(viewModel.allSongs.count) Songs")
                        .font(SaltTypography.subheadline)
                        .foregroundColor(SaltColors.accent)
                }
            }
        }
    }

    @ViewBuilder
    private var albumsSection: some View {
        VStack(alignment: .leading, spacing: SaltTheme.spacingM) {
            SectionHeader(title: "Albums")

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: SaltTheme.spacingM)
            ], spacing: SaltTheme.spacingM) {
                ForEach(viewModel.albums) { album in
                    AlbumCardView(album: album, size: 150) {
                        // Navigate to album detail
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: SaltTheme.spacingM) {
            SectionHeader(title: "Favorites", subtitle: "\(viewModel.favoriteSongs.count) songs")

            ForEach(viewModel.favoriteSongs.prefix(3)) { song in
                SongRowView(song: song) {
                    playerViewModel.play(song: song, in: viewModel.favoriteSongs)
                }
                Divider()
                    .background(SaltColors.divider)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: SaltTheme.spacingXL) {
            Spacer()

            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundColor(SaltColors.textTertiary)

            VStack(spacing: SaltTheme.spacingM) {
                Text("No Music Yet")
                    .saltTitle1()

                Text("Import music from your device to get started")
                    .saltSecondary()
                    .multilineTextAlignment(.center)
            }

            Button(action: { libraryViewModel.showImportSheet = true }) {
                HStack {
                    Image(systemName: "folder.badge.plus")
                    Text("Import Music")
                }
                .font(SaltTypography.headline)
                .foregroundColor(.white)
                .padding(.horizontal, SaltTheme.spacingXL)
                .padding(.vertical, SaltTheme.spacingM)
                .background(SaltGradient.accent)
                .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(SaltTheme.spacingXL)
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil
    var actionLabel: String? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: SaltTheme.spacingXXS) {
                Text(title)
                    .saltTitle2()

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(SaltTypography.caption1)
                        .foregroundColor(SaltColors.textSecondary)
                }
            }

            Spacer()

            if let action = action, let actionLabel = actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .font(SaltTypography.subheadline)
                        .foregroundColor(SaltColors.accent)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(PlayerViewModel())
        .environmentObject(LibraryViewModel())
}
