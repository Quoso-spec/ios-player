import SwiftUI

struct ContentView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State private var selectedTab: Tab = .home
    @State private var showPlayer: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(Tab.home)
                    .tabItem {
                        Label("首页", systemImage: "house.fill")
                    }

                LibraryView()
                    .tag(Tab.library)
                    .tabItem {
                        Label("音乐库", systemImage: "music.note.list")
                    }

                PlaylistsView()
                    .tag(Tab.playlists)
                    .tabItem {
                        Label("播放列表", systemImage: "music.note.list")
                    }

                SettingsView()
                    .tag(Tab.settings)
                    .tabItem {
                        Label("设置", systemImage: "gearshape.fill")
                    }
            }
            .tint(SaltColors.accent)

            if playerViewModel.currentSong != nil {
                VStack(spacing: 0) {
                    MiniPlayerView(showPlayer: $showPlayer)
                    Spacer().frame(height: 49)
                }
            }
        }
        .sheet(isPresented: $showPlayer) {
            PlayerView()
        }
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(SaltColors.background)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

enum Tab: Hashable {
    case home
    case library
    case playlists
    case settings
}

#Preview {
    ContentView()
        .environmentObject(PlayerViewModel())
        .environmentObject(LibraryViewModel())
}
