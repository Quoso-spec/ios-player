import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist

    @StateObject private var viewModel = PlaylistViewModel()
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State private var showEditSheet = false

    private var songs: [Song] {
        viewModel.songs(for: playlist)
    }

    var body: some View {
        List {
            playlistHeader

            if songs.isEmpty {
                emptyState
            } else {
                songsSection
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(SaltColors.background)
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { viewModel.toggleFavorite(playlist) }) {
                        Label(
                            playlist.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: playlist.isFavorite ? "heart.slash" : "heart"
                        )
                    }

                    Button(action: { viewModel.duplicatePlaylist(playlist) }) {
                        Label("Duplicate Playlist", systemImage: "doc.on.doc")
                    }

                    Button(role: .destructive, action: { viewModel.deletePlaylist(playlist) }) {
                        Label("Delete Playlist", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(SaltColors.accent)
                }
            }
        }
    }

    @ViewBuilder
    private var playlistHeader: some View {
        Section {
            VStack(spacing: SaltTheme.spacingM) {
                ZStack {
                    RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusLarge)
                        .fill(SaltColors.surfaceElevated)
                        .frame(width: 160, height: 160)

                    if let artworkData = playlist.artworkData,
                       let uiImage = UIImage(data: artworkData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusLarge))
                    } else {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(SaltColors.textTertiary)
                    }
                }

                VStack(spacing: SaltTheme.spacingS) {
                    Text("\(songs.count) songs")
                        .font(SaltTypography.subheadline)
                        .foregroundColor(SaltColors.textSecondary)

                    Text(viewModel.totalDuration(for: playlist))
                        .font(SaltTypography.caption1)
                        .foregroundColor(SaltColors.textTertiary)
                }

                Button(action: {
                    if !songs.isEmpty {
                        playerViewModel.play(songs: songs)
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play All")
                    }
                    .font(SaltTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SaltTheme.spacingM)
                    .background(SaltGradient.accent)
                    .clipShape(Capsule())
                }
                .disabled(songs.isEmpty)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private var songsSection: some View {
        ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
            SongRowView(song: song, onTap: {
                playerViewModel.play(song: song, in: songs)
            })
            .listRowBackground(SaltColors.background)
        }
        .onDelete { offsets in
            for offset in offsets {
                viewModel.removeSong(songs[offset], from: playlist)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        Section {
            VStack(spacing: SaltTheme.spacingM) {
                Image(systemName: "music.note")
                    .font(.system(size: 40))
                    .foregroundColor(SaltColors.textTertiary)

                Text("No songs in this playlist")
                    .font(SaltTypography.subheadline)
                    .foregroundColor(SaltColors.textSecondary)

                Text("Add songs from your library")
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SaltTheme.spacingXXL)
            .listRowBackground(Color.clear)
        }
    }
}

#Preview {
    NavigationStack {
        PlaylistDetailView(playlist: Playlist(name: "Test Playlist"))
    }
    .environmentObject(PlayerViewModel())
}
