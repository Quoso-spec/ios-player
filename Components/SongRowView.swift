import SwiftUI

struct SongRowView: View {
    let song: Song
    let showAlbum: Bool
    let showDuration: Bool
    let onTap: () -> Void
    let onMoreTap: (() -> Void)?

    @EnvironmentObject var playerViewModel: PlayerViewModel

    init(
        song: Song,
        showAlbum: Bool = true,
        showDuration: Bool = true,
        onTap: @escaping () -> Void = {},
        onMoreTap: (() -> Void)? = nil
    ) {
        self.song = song
        self.showAlbum = showAlbum
        self.showDuration = showDuration
        self.onTap = onTap
        self.onMoreTap = onMoreTap
    }

    private var isPlaying: Bool {
        playerViewModel.currentSong?.id == song.id
    }

    var body: some View {
        HStack(spacing: SaltTheme.spacingM) {
            CoverImageView(
                data: song.artworkData,
                size: SaltTheme.albumCoverSizeSmall
            )

            VStack(alignment: .leading, spacing: SaltTheme.spacingXXS) {
                Text(song.title)
                    .font(SaltTypography.headline)
                    .foregroundColor(isPlaying ? SaltColors.accent : SaltColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: SaltTheme.spacingS) {
                    if showAlbum {
                        Text(song.artist)
                            .font(SaltTypography.subheadline)
                            .foregroundColor(SaltColors.textSecondary)
                            .lineLimit(1)
                    }

                    if song.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(SaltColors.error)
                    }
                }
            }

            Spacer()

            if showDuration {
                Text(song.formattedDuration)
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textTertiary)
            }

            if let moreTap = onMoreTap {
                Button(action: moreTap) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SaltColors.textSecondary)
                }
                .buttonStyle(.plain)
                .frame(width: 32, height: 32)
            }
        }
        .padding(.vertical, SaltTheme.spacingS)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct SongRowCompactView: View {
    let song: Song
    let onTap: () -> Void

    @EnvironmentObject var playerViewModel: PlayerViewModel

    private var isPlaying: Bool {
        playerViewModel.currentSong?.id == song.id
    }

    var body: some View {
        HStack(spacing: SaltTheme.spacingM) {
            CoverImageView(
                data: song.artworkData,
                size: 40
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(SaltTypography.subheadline)
                    .foregroundColor(isPlaying ? SaltColors.accent : SaltColors.textPrimary)
                    .lineLimit(1)

                Text(song.artist)
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if isPlaying {
                PlayingIndicatorView()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct PlayingIndicatorView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(SaltColors.accent)
                    .frame(width: 3, height: isAnimating ? 12 : 6)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
    }
}

#Preview {
    VStack {
        SongRowView(
            song: Song(
                title: "Test Song",
                artist: "Test Artist",
                album: "Test Album",
                filePath: "/test.mp3",
                isFavorite: true
            ),
            onTap: {},
            onMoreTap: {}
        )

        SongRowCompactView(
            song: Song(
                title: "Another Song",
                artist: "Another Artist",
                filePath: "/test2.mp3"
            ),
            onTap: {}
        )
    }
    .padding()
    .background(SaltColors.background)
    .environmentObject(PlayerViewModel())
}
