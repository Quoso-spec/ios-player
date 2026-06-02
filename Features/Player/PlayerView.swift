import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLyrics = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient

                VStack(spacing: 0) {
                    dismissHandle

                    if showLyrics {
                        lyricsContent(geometry: geometry)
                    } else {
                        albumContent(geometry: geometry)
                    }

                    playbackControls
                    progressSection
                    bottomControls
                }
                .padding(.horizontal, SaltTheme.spacingXL)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            dismiss()
                        }
                        dragOffset = 0
                    }
            )
        }
        .offset(y: dragOffset)
        .animation(.interactiveSpring(), value: dragOffset)
        .onAppear {
            showLyrics = playerViewModel.showLyrics
        }
    }

    @ViewBuilder
    private var backgroundGradient: some View {
        if let song = playerViewModel.currentSong,
           let data = song.artworkData,
           let uiImage = UIImage(data: data) {
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 50)
                    .opacity(0.5)

                Color.black.opacity(0.6)
            }
            .ignoresSafeArea()
        } else {
            SaltColors.background
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var dismissHandle: some View {
        Capsule()
            .fill(Color.white.opacity(0.3))
            .frame(width: 36, height: 4)
            .padding(.top, SaltTheme.spacingS)
            .padding(.bottom, SaltTheme.spacingM)
    }

    @ViewBuilder
    private func albumContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: SaltTheme.spacingXL) {
            Spacer()

            CoverImageAsyncView(
                data: playerViewModel.currentSong?.artworkData,
                size: min(geometry.size.width - 64, SaltTheme.albumCoverSizeXLarge),
                cornerRadius: SaltTheme.cornerRadiusLarge
            )
            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)

            songInfo
                .opacity(0)

            Spacer()
        }
    }

    @ViewBuilder
    private func lyricsContent(geometry: GeometryProxy) -> some View {
        LyricsDisplayView()
    }

    @ViewBuilder
    private var songInfo: some View {
        VStack(spacing: SaltTheme.spacingS) {
            if let song = playerViewModel.currentSong {
                Text(song.title)
                    .font(SaltTypography.title2)
                    .foregroundColor(SaltColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(song.artist)
                    .font(SaltTypography.body)
                    .foregroundColor(SaltColors.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private var playbackControls: some View {
        VStack(spacing: SaltTheme.spacingXL) {
            songInfo
                .opacity(1)

            HStack(spacing: SaltTheme.spacingXXL) {
                Button(action: { playerViewModel.previous() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 32))
                        .foregroundColor(SaltColors.textPrimary)
                }
                .buttonStyle(.plain)

                Button(action: { playerViewModel.togglePlayPause() }) {
                    ZStack {
                        Circle()
                            .fill(SaltGradient.accent)
                            .frame(width: 72, height: 72)

                        Image(systemName: playerViewModel.playbackState.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .offset(x: playerViewModel.playbackState.isPlaying ? 0 : 2)
                    }
                }
                .buttonStyle(.plain)

                Button(action: { playerViewModel.next() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 32))
                        .foregroundColor(SaltColors.textPrimary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var progressSection: some View {
        VStack(spacing: SaltTheme.spacingS) {
            AnimatedProgressBar(
                value: Binding(
                    get: { playerViewModel.progress },
                    set: { playerViewModel.seekToProgress($0) }
                ),
                onEditingChanged: { _ in }
            )
            .frame(height: 20)

            HStack {
                Text(playerViewModel.formattedCurrentTime)
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textSecondary)

                Spacer()

                Text(playerViewModel.formattedRemainingTime)
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textSecondary)
            }
        }
        .padding(.vertical, SaltTheme.spacingM)
    }

    @ViewBuilder
    private var bottomControls: some View {
        HStack {
            Button(action: { showLyrics.toggle() }) {
                Image(systemName: "text.quote")
                    .font(.system(size: 20))
                    .foregroundColor(showLyrics ? SaltColors.accent : SaltColors.textSecondary)
            }

            Spacer()

            HStack(spacing: SaltTheme.spacingXL) {
                Button(action: { playerViewModel.toggleShuffle() }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 18))
                        .foregroundColor(playerViewModel.shuffleMode.isActive ? SaltColors.accent : SaltColors.textSecondary)
                }

                Button(action: { playerViewModel.toggleRepeat() }) {
                    Image(systemName: playerViewModel.repeatMode.icon)
                        .font(.system(size: 18))
                        .foregroundColor(playerViewModel.repeatMode.isActive ? SaltColors.accent : SaltColors.textSecondary)
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundColor(SaltColors.textSecondary)
            }
        }
        .padding(.bottom, SaltTheme.spacingXXL)
    }
}

#Preview {
    PlayerView()
        .environmentObject(PlayerViewModel())
}
