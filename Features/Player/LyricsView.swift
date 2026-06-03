import SwiftUI

struct LyricsDisplayView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @StateObject private var lyricsEngine = LyricsSyncEngine.shared

    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        if lyricsEngine.isLoading {
            loadingView
        } else if lyricsEngine.currentLyrics.isEmpty {
            emptyView
        } else {
            lyricsScrollView
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(SaltColors.accent)
            Text("Loading lyrics...")
                .font(SaltTypography.subheadline)
                .foregroundColor(SaltColors.textSecondary)
            Spacer()
        }
    }

    @ViewBuilder
    private var emptyView: some View {
        VStack {
            Spacer()
            Image(systemName: "text.quote")
                .font(.system(size: 48))
                .foregroundColor(SaltColors.textTertiary)
            Text("No lyrics available")
                .font(SaltTypography.headline)
                .foregroundColor(SaltColors.textSecondary)
            Text("Place an .lrc file next to the audio file")
                .font(SaltTypography.caption1)
                .foregroundColor(SaltColors.textTertiary)
            Spacer()
        }
    }

    @ViewBuilder
    private var lyricsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: SaltTheme.spacingXL) {
                    Spacer()
                        .frame(height: 100)

                    ForEach(Array(lyricsEngine.currentLyrics.lines.enumerated()), id: \.element.id) { index, line in
                        LyricLineView(
                            line: line,
                            isActive: index == lyricsEngine.currentLineIndex,
                            isPast: index < (lyricsEngine.currentLineIndex ?? -1)
                        )
                        .id(line.id)
                    }

                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, SaltTheme.spacingXL)
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: lyricsEngine.currentLineIndex) { _, newIndex in
                if let index = newIndex {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if let line = lyricsEngine.currentLyrics.lines[safe: index] {
                            proxy.scrollTo(line.id, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}

struct LyricLineView: View {
    let line: LyricLine
    let isActive: Bool
    let isPast: Bool

    var body: some View {
        Text(line.text)
            .font(isActive ? SaltTypography.lyricsCurrent : SaltTypography.lyricsNormal)
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.2), value: isActive)
    }

    private var textColor: Color {
        if isActive {
            return SaltColors.textPrimary
        } else if isPast {
            return SaltColors.textTertiary
        } else {
            return SaltColors.textSecondary
        }
    }

    private var opacity: Double {
        if isActive {
            return 1.0
        } else if isPast {
            return 0.4
        } else {
            return 0.7
        }
    }
}

extension Array {
    static subscript<T>(array: [T], index: Int) -> T? {
        return indices.contains(index) ? array[index] : nil
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    LyricsDisplayView()
        .environmentObject(PlayerViewModel())
        .background(SaltColors.background)
}
