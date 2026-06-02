import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @EnvironmentObject var playerViewModel: PlayerViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                segmentedControl

                if viewModel.isScanning {
                    scanningIndicator
                } else {
                    libraryContent
                }
            }
            .background(SaltColors.background)
            .navigationTitle("Library")
            .searchable(text: $viewModel.searchQuery, prompt: "Search songs, albums, artists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button(action: { viewModel.setSortOrder(order) }) {
                                Label(order.rawValue, systemImage: order.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(SaltColors.accent)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.showImportSheet = true }) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(SaltColors.accent)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showImportSheet) {
                DocumentPickerView { url in
                    viewModel.scanDirectory(url)
                }
            }
        }
    }

    @ViewBuilder
    private var segmentedControl: some View {
        Picker("View", selection: $viewModel.selectedGrouping) {
            ForEach(LibraryViewModel.LibraryGrouping.allCases, id: \.self) { grouping in
                Text(grouping.rawValue).tag(grouping)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, SaltTheme.spacingL)
        .padding(.vertical, SaltTheme.spacingS)
    }

    @ViewBuilder
    private var scanningIndicator: some View {
        VStack(spacing: SaltTheme.spacingL) {
            Spacer()
            ProgressView(value: viewModel.scanProgress)
                .tint(SaltColors.accent)
                .padding(.horizontal, SaltTheme.spacingXXL)

            Text("Scanning... \(Int(viewModel.scanProgress * 100))%")
                .font(SaltTypography.subheadline)
                .foregroundColor(SaltColors.textSecondary)

            Spacer()
        }
    }

    @ViewBuilder
    private var libraryContent: some View {
        Group {
            switch viewModel.selectedGrouping {
            case .songs:
                songsList
            case .albums:
                albumsGrid
            case .artists:
                artistsList
            }
        }
    }

    @ViewBuilder
    private var songsList: some View {
        List {
            if viewModel.isSearching {
                ForEach(viewModel.searchResults) { song in
                    SongRowView(song: song, onTap: {
                        playerViewModel.play(song: song, in: viewModel.displayedSongs)
                    })
                    .listRowBackground(SaltColors.background)
                }
            } else {
                ForEach(viewModel.displayedSongs) { song in
                    SongRowView(song: song, onTap: {
                        let index = viewModel.displayedSongs.firstIndex(where: { $0.id == song.id }) ?? 0
                        playerViewModel.play(songs: viewModel.displayedSongs, startingAt: index)
                    })
                    .listRowBackground(SaltColors.background)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private var albumsGrid: some View {
        ScrollView {
            AlbumGridView(albums: viewModel.albums) { album in
                // Navigate to album detail
            }
            .padding(.horizontal, SaltTheme.spacingL)
            .padding(.bottom, SaltTheme.miniPlayerHeight + 20)
        }
    }

    @ViewBuilder
    private var artistsList: some View {
        List {
            ForEach(viewModel.artists) { artist in
                ArtistRowView(artist: artist) {
                    // Navigate to artist detail
                }
                .listRowBackground(SaltColors.background)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    LibraryView()
        .environmentObject(PlayerViewModel())
        .environmentObject(LibraryViewModel())
}
