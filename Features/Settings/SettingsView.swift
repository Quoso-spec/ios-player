import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        SettingsContent(environment: environment, theme: environment.theme)
    }
}

private struct SettingsContent: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject var theme: SaltTheme
    @State private var mediaLibraryStatus: SystemMediaLibraryStatus = .notDetermined

    var body: some View {
        NavigationStack {
            Form {
                Section("外观") {
                    Picker("主题", selection: $theme.variant) {
                        ForEach(SaltThemeVariant.allCases) { variant in
                            Text(label(for: variant)).tag(variant)
                        }
                    }

                    Picker("播放器背景", selection: $theme.playerBackgroundStyle) {
                        Text("流动渐变").tag(PlayerBackgroundStyle.fluidGradient)
                        Text("封面模糊").tag(PlayerBackgroundStyle.blurredArtwork)
                        Text("安静材质").tag(PlayerBackgroundStyle.calmMaterial)
                    }
                }

                Section("媒体库") {
                    LabeledContent("数据库", value: environment.libraryStore.databaseURL.lastPathComponent)
                    LabeledContent("系统媒体库", value: label(for: mediaLibraryStatus))
                    Button {
                        Task {
                            mediaLibraryStatus = await environment.systemMediaLibraryProvider.requestAuthorization()
                        }
                    } label: {
                        Label("授权系统媒体库", systemImage: "music.note.house")
                    }
                }

                Section("分发") {
                    LabeledContent("Bundle ID", value: "com.moriafly.saltplayer.ios.dev")
                    LabeledContent("最低系统", value: "iOS 17")
                    LabeledContent("签名", value: "企业 / 自签占位")
                }

                Section("维护") {
                    Button {
                        Task {
                            _ = await environment.diagnosticsService.makeSnapshot()
                        }
                    } label: {
                        Label("生成诊断快照", systemImage: "stethoscope")
                    }
                    Button {
                    } label: {
                        Label("备份与恢复占位", systemImage: "externaldrive")
                    }
                    .disabled(true)
                }
            }
            .navigationTitle("设置")
            .task {
                mediaLibraryStatus = environment.systemMediaLibraryProvider.authorizationStatus()
            }
        }
    }

    private func label(for variant: SaltThemeVariant) -> String {
        switch variant {
        case .dusk:
            return "椒盐暮色"
        case .light:
            return "清亮"
        case .midnight:
            return "午夜"
        case .graphite:
            return "石墨"
        }
    }

    private func label(for status: SystemMediaLibraryStatus) -> String {
        switch status {
        case .unsupported:
            return "未接入"
        case .notDetermined:
            return "未决定"
        case .denied:
            return "未授权"
        case .authorized:
            return "已授权"
        }
    }
}
