import SwiftUI

struct RootView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        TabView {
            LibraryView()
                .tabItem {
                    Label("曲库", systemImage: "music.note.list")
                }

            PlayerView()
                .tabItem {
                    Label("播放", systemImage: "play.circle.fill")
                }

            LyricsView()
                .tabItem {
                    Label("歌词", systemImage: "quote.bubble")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "slider.horizontal.3")
                }
        }
        .background(environment.theme.palette.background)
    }
}

