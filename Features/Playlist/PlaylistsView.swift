import SwiftUI

struct PlaylistsView: View {
    @StateObject private var viewModel = PlaylistViewModel()
    @EnvironmentObject var playerViewModel: PlayerViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.playlists.isEmpty {
                    emptyState
                } else {
                    playlistsList
                }
            }
            .background(SaltColors.background)
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.showCreateSheet = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(SaltColors.accent)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateSheet) {
                createPlaylistSheet
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: SaltTheme.spacingL) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(SaltColors.textTertiary)

            Text("No playlists yet")
                .font(SaltTypography.headline)
                .foregroundColor(SaltColors.textSecondary)

            Text("Create your first playlist")
                .font(SaltTypography.subheadline)
                .foregroundColor(SaltColors.textTertiary)

            Button(action: { viewModel.showCreateSheet = true }) {
                Text("Create Playlist")
                    .font(SaltTypography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, SaltTheme.spacingXL)
                    .padding(.vertical, SaltTheme.spacingM)
                    .background(SaltGradient.accent)
                    .clipShape(Capsule())
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var playlistsList: some View {
        List {
            if !viewModel.favoritePlaylists.isEmpty {
                Section("Favorites") {
                    ForEach(viewModel.favoritePlaylists) { playlist in
                        PlaylistRowView(playlist: playlist) {
                            // Navigate to detail
                        }
                        .listRowBackground(SaltColors.background)
                    }
                    .onDelete { offsets in
                        for offset in offsets {
                            viewModel.deletePlaylist(viewModel.favoritePlaylists[offset])
                        }
                    }
                }
            }

            Section("All Playlists") {
                ForEach(viewModel.recentPlaylists) { playlist in
                    NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                        PlaylistRowView(playlist: playlist) {}
                    }
                    .listRowBackground(SaltColors.background)
                }
                .onDelete { offsets in
                    for offset in offsets {
                        viewModel.deletePlaylist(viewModel.recentPlaylists[offset])
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private var createPlaylistSheet: some View {
        NavigationStack {
            Form {
                Section("Playlist Name") {
                    TextField("Name", text: $viewModel.newPlaylistName)
                }

                Section("Description (Optional)") {
                    TextField("Description", text: $viewModel.newPlaylistDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showCreateSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        viewModel.createPlaylist()
                    }
                    .disabled(viewModel.newPlaylistName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct PlaylistRowView: View {
    let playlist: Playlist
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: SaltTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusSmall)
                    .fill(SaltColors.surfaceElevated)
                    .frame(width: 56, height: 56)

                if let artworkData = playlist.artworkData,
                   let uiImage = UIImage(data: artworkData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusSmall))
                } else {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 24))
                        .foregroundColor(SaltColors.textTertiary)
                }
            }

            VStack(alignment: .leading, spacing: SaltTheme.spacingXXS) {
                HStack {
                    Text(playlist.name)
                        .font(SaltTypography.headline)
                        .foregroundColor(SaltColors.textPrimary)

                    if playlist.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(SaltColors.error)
                    }
                }

                Text("\(playlist.songCount) songs")
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, SaltTheme.spacingXS)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    PlaylistsView()
        .environmentObject(PlayerViewModel())
}
