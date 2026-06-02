import SwiftUI

struct LyricsView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        LyricsContent(engine: environment.playbackEngine, lyricsProvider: environment.lyricsProvider, theme: environment.theme)
    }
}

private struct LyricsContent: View {
    @ObservedObject var engine: AVQueuePlaybackEngine
    let lyricsProvider: any LyricsProvider
    @ObservedObject var theme: SaltTheme

    @State private var lyrics: LyricsDocument?
    @State private var loadMessage: String?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        if let lyrics {
                            ForEach(lyrics.lines) { line in
                                Text(line.text.isEmpty ? " " : line.text)
                                    .id(line.id)
                                    .font(.system(size: isActive(line, in: lyrics) ? 24 : 18, weight: isActive(line, in: lyrics) ? .semibold : .regular))
                                    .foregroundStyle(isActive(line, in: lyrics) ? theme.palette.primaryText : theme.palette.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        } else {
                            ContentUnavailableView("暂无歌词", systemImage: "quote.bubble", description: Text(loadMessage ?? ""))
                                .padding(.top, 120)
                        }
                    }
                    .padding(24)
                }
                .background(theme.palette.background)
                .navigationTitle("歌词")
                .task(id: engine.currentTrack?.id) {
                    await loadLyrics()
                }
                .onChange(of: engine.progress) {
                    guard let lyrics, let active = lyrics.activeLine(at: engine.progress) else {
                        return
                    }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(active.id, anchor: .center)
                    }
                }
            }
        }
    }

    private func loadLyrics() async {
        guard let track = engine.currentTrack else {
            lyrics = nil
            loadMessage = "选择一首歌后显示歌词"
            return
        }

        do {
            if let localLyrics = try await lyricsProvider.findLocalLyrics(for: track) {
                lyrics = localLyrics
            } else {
                lyrics = try await lyricsProvider.findEmbeddedLyrics(for: track)
            }
            loadMessage = lyrics == nil ? "未找到本地或内嵌歌词" : nil
        } catch {
            lyrics = nil
            loadMessage = "歌词读取失败：\(error.localizedDescription)"
        }
    }

    private func isActive(_ line: LyricLine, in lyrics: LyricsDocument) -> Bool {
        lyrics.activeLine(at: engine.progress)?.id == line.id
    }
}
