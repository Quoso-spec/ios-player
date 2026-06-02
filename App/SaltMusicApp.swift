import SwiftUI

@main
struct SaltMusicApp: App {
    @StateObject private var environment: AppEnvironment

    init() {
        _environment = StateObject(wrappedValue: AppEnvironment.live())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(environment)
                .tint(environment.theme.palette.accent)
        }
    }
}

