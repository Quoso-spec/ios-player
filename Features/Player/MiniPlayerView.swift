import SwiftUI

struct MiniPlayerView: View {
    @Binding var showPlayer: Bool
    @EnvironmentObject var playerViewModel: PlayerViewModel

    var body: some View {
        if let song = playerViewModel.currentSong {
            VStack(spacing: 0) {
                miniProgressBar

                HStack(spacing: SaltTheme.spacingM) {
                    CoverImageView(
                        data: song.artworkData,
                        size: SaltTheme.albumCoverSizeSmall
                    )
                    .onTapGesture {
                        showPlayer = true
                    }

                    songInfo(for: song)

                    Spacer()

                    controls
                }
                .padding(.horizontal, SaltTheme.spacingM)
                .padding(.vertical, SaltTheme.spacingS)
            }
            .background(
                BlurView(style: .systemThinMaterialDark)
                    .overlay(SaltColors.surface.opacity(0.8))
            )
            .contentShape(Rectangle())
            .onTapGesture {
                showPlayer = true
            }
        }
    }

    @ViewBuilder
    private var miniProgressBar: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(SaltGradient.accent)
                .frame(width: geometry.size.width * playerViewModel.progress, height: 2)
        }
        .frame(height: 2)
    }

    @ViewBuilder
    private func songInfo(for song: Song) -> some View {
        VStack(alignment: .leading, spacing: SaltTheme.spacingXXS) {
            Text(song.title)
                .font(SaltTypography.subheadline)
                .foregroundColor(SaltColors.textPrimary)
                .lineLimit(1)

            Text(song.artist)
                .font(SaltTypography.caption1)
                .foregroundColor(SaltColors.textSecondary)
                .lineLimit(1)
        }
        .onTapGesture {
            showPlayer = true
        }
    }

    @ViewBuilder
    private var controls: some View {
        HStack(spacing: SaltTheme.spacingM) {
            Button(action: { playerViewModel.togglePlayPause() }) {
                Image(systemName: playerViewModel.playbackState.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 22))
                    .foregroundColor(SaltColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Button(action: { playerViewModel.next() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 18))
                    .foregroundColor(SaltColors.textPrimary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
        }
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView(showPlayer: .constant(false))
            .environmentObject(PlayerViewModel())
    }
    .background(SaltColors.background)
}
