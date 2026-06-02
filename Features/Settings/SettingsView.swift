import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                audioSection
                playbackSection
                librarySection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SaltColors.background)
            .navigationTitle("Settings")
        }
    }

    @ViewBuilder
    private var audioSection: some View {
        Section {
            NavigationLink(destination: EqualizerView()) {
                SettingsRow(
                    icon: "slider.horizontal.3",
                    title: "Equalizer",
                    iconColor: SaltColors.accent
                )
            }
        } header: {
            Text("Audio")
        }
        .listRowBackground(SaltColors.surface)
    }

    @ViewBuilder
    private var playbackSection: some View {
        Section {
            Toggle(isOn: $viewModel.crossfadeEnabled) {
                SettingsRow(
                    icon: "arrow.left.arrow.right",
                    title: "Crossfade",
                    iconColor: .orange
                )
            }
            .tint(SaltColors.accent)

            if viewModel.crossfadeEnabled {
                VStack(alignment: .leading, spacing: SaltTheme.spacingS) {
                    HStack {
                        Text("Duration")
                            .font(SaltTypography.subheadline)
                        Spacer()
                        Text("\(Int(viewModel.crossfadeDuration))s")
                            .font(SaltTypography.subheadline)
                            .foregroundColor(SaltColors.textSecondary)
                    }

                    Slider(value: $viewModel.crossfadeDuration, in: 0.5...12, step: 0.5)
                        .tint(SaltColors.accent)
                }
                .padding(.vertical, SaltTheme.spacingXS)
            }

            Toggle(isOn: $viewModel.gaplessPlayback) {
                SettingsRow(
                    icon: "waveform",
                    title: "Gapless Playback",
                    iconColor: .green
                )
            }
            .tint(SaltColors.accent)
        } header: {
            Text("Playback")
        }
        .listRowBackground(SaltColors.surface)
    }

    @ViewBuilder
    private var librarySection: some View {
        Section {
            HStack {
                SettingsRow(
                    icon: "music.note",
                    title: "Songs",
                    iconColor: .blue
                )
                Spacer()
                Text("\(viewModel.songCount)")
                    .font(SaltTypography.subheadline)
                    .foregroundColor(SaltColors.textSecondary)
            }

            HStack {
                SettingsRow(
                    icon: "square.stack",
                    title: "Albums",
                    iconColor: .purple
                )
                Spacer()
                Text("\(viewModel.albumCount)")
                    .font(SaltTypography.subheadline)
                    .foregroundColor(SaltColors.textSecondary)
            }

            HStack {
                SettingsRow(
                    icon: "externaldrive",
                    title: "Storage Used",
                    iconColor: .gray
                )
                Spacer()
                Text(viewModel.storageUsed)
                    .font(SaltTypography.subheadline)
                    .foregroundColor(SaltColors.textSecondary)
            }

            Toggle(isOn: $viewModel.autoScanOnLaunch) {
                SettingsRow(
                    icon: "arrow.clockwise",
                    title: "Scan on Launch",
                    iconColor: .cyan
                )
            }
            .tint(SaltColors.accent)
        } header: {
            Text("Library")
        }
        .listRowBackground(SaltColors.surface)
    }

    @ViewBuilder
    private var aboutSection: some View {
        Section {
            HStack {
                SettingsRow(
                    icon: "info.circle",
                    title: "Version",
                    iconColor: .gray
                )
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .font(SaltTypography.subheadline)
                    .foregroundColor(SaltColors.textSecondary)
            }

            Button(action: { viewModel.resetToDefaults() }) {
                SettingsRow(
                    icon: "arrow.counterclockwise",
                    title: "Reset to Defaults",
                    iconColor: .red
                )
            }
        } header: {
            Text("About")
        }
        .listRowBackground(SaltColors.surface)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: SaltTheme.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(title)
                .font(SaltTypography.body)
                .foregroundColor(SaltColors.textPrimary)
        }
    }
}

#Preview {
    SettingsView()
}
