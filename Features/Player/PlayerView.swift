import Foundation
import SwiftUI

struct PlayerView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        PlayerContent(engine: environment.playbackEngine, theme: environment.theme)
    }
}

private struct PlayerContent: View {
    @ObservedObject var engine: AVQueuePlaybackEngine
    @ObservedObject var theme: SaltTheme
    @StateObject private var viewModel = PlayerViewModel()
    @State private var scrubPosition: Double = 0
    @State private var isScrubbing = false

    var body: some View {
        ZStack {
            playerBackground
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 18)

                artwork

                VStack(spacing: 8) {
                    Text(engine.currentTrack?.displayTitle ?? "未在播放")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(theme.palette.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text(engine.currentTrack?.displayArtist ?? "选择一首歌开始")
                        .font(.body)
                        .foregroundStyle(theme.palette.secondaryText)
                        .lineLimit(1)
                }
                .padding(.horizontal, 24)

                progressControl
                    .padding(.horizontal, 24)

                playbackControls

                audioStrip
                    .padding(.horizontal, 20)

                Spacer(minLength: 24)
            }
        }
        .onChange(of: engine.progress) {
            if !isScrubbing {
                scrubPosition = engine.progress
            }
        }
    }

    private var playerBackground: some View {
        LinearGradient(
            colors: [
                theme.palette.background,
                theme.palette.coolAccent.opacity(0.45),
                theme.palette.warmAccent.opacity(0.35),
                theme.palette.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var artwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    LinearGradient(
                        colors: [theme.palette.accent.opacity(0.50), theme.palette.coolAccent.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            Image(systemName: "music.quarternote.3")
                .font(.system(size: 76, weight: .light))
                .foregroundStyle(theme.palette.primaryText.opacity(0.86))
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 310)
        .padding(.horizontal, 36)
        .shadow(color: .black.opacity(0.24), radius: 22, y: 12)
    }

    private var progressControl: some View {
        VStack(spacing: 8) {
            Slider(
                value: $scrubPosition,
                in: 0...max(engine.duration, 1),
                onEditingChanged: { editing in
                    isScrubbing = editing
                    if !editing {
                        engine.seek(to: scrubPosition)
                    }
                }
            )
            HStack {
                Text(formatTime(isScrubbing ? scrubPosition : engine.progress))
                Spacer()
                Text(formatTime(engine.duration))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(theme.palette.secondaryText)
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 28) {
            Button {
                engine.setShuffleEnabled(!engine.state.isShuffleEnabled)
            } label: {
                Image(systemName: "shuffle")
            }
            .foregroundStyle(engine.state.isShuffleEnabled ? theme.palette.accent : theme.palette.primaryText)
            .help("随机播放")

            Button {
                engine.skipPrevious()
            } label: {
                Image(systemName: "backward.fill")
            }
            .help("上一首")

            Button {
                if engine.state.status == .playing {
                    engine.pause()
                } else {
                    engine.play()
                }
            } label: {
                Image(systemName: engine.state.status == .playing ? "pause.fill" : "play.fill")
                    .font(.system(size: 28, weight: .bold))
                    .frame(width: 68, height: 68)
                    .background(theme.palette.primaryText)
                    .foregroundStyle(theme.palette.background)
                    .clipShape(Circle())
            }
            .help(engine.state.status == .playing ? "暂停" : "播放")

            Button {
                engine.skipNext()
            } label: {
                Image(systemName: "forward.fill")
            }
            .help("下一首")

            Button {
                let next: RepeatMode = switch engine.state.repeatMode {
                case .off: .all
                case .all: .one
                case .one: .off
                }
                engine.setRepeatMode(next)
            } label: {
                Image(systemName: engine.state.repeatMode == .one ? "repeat.1" : "repeat")
            }
            .foregroundStyle(engine.state.repeatMode == .off ? theme.palette.primaryText : theme.palette.accent)
            .help("循环模式")
        }
        .font(.title3)
        .buttonStyle(.plain)
        .foregroundStyle(theme.palette.primaryText)
    }

    private var audioStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("EQ", systemImage: "slider.horizontal.3")
                    .font(.headline)
                Spacer()
                Text(viewModel.advancedAudioConfiguration.replayGainEnabled ? "ReplayGain" : "Direct")
                    .font(.caption)
                    .foregroundStyle(theme.palette.secondaryText)
            }

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(viewModel.advancedAudioConfiguration.equalizerBands, id: \.frequency) { band in
                    VStack(spacing: 6) {
                        Capsule()
                            .fill(theme.palette.accent.opacity(0.85))
                            .frame(width: 8, height: CGFloat(max(12.0, 36.0 + band.gain * 2.0)))
                        Text("\(Int(band.frequency))")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(theme.palette.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .foregroundStyle(theme.palette.primaryText)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite else {
            return "00:00"
        }
        let total = max(Int(seconds), 0)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
