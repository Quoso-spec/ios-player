import SwiftUI

struct EqualizerView: View {
    @StateObject private var viewModel = EqualizerViewModel()
    @Environment(\.dismiss) private var dismiss

    private let bandLabels = ["32", "64", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                enableToggle

                if viewModel.isEnabled {
                    presetPicker
                    bandSliders
                } else {
                    disabledState
                }
            }
            .background(SaltColors.background)
            .navigationTitle("Equalizer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(SaltColors.accent)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        viewModel.reset()
                    }
                    .foregroundColor(SaltColors.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private var enableToggle: some View {
        Toggle(isOn: $viewModel.isEnabled) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(SaltColors.accent)

                Text("Equalizer")
                    .font(SaltTypography.headline)
            }
        }
        .tint(SaltColors.accent)
        .padding(SaltTheme.spacingL)
    }

    @ViewBuilder
    private var presetPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SaltTheme.spacingS) {
                ForEach(EQPreset.allCases.filter { $0 != .custom }, id: \.self) { preset in
                    Button(action: { viewModel.applyPreset(preset) }) {
                        HStack(spacing: SaltTheme.spacingXXS) {
                            Image(systemName: preset.icon)
                                .font(.caption)

                            Text(preset.rawValue)
                                .font(SaltTypography.caption1)
                        }
                        .padding(.horizontal, SaltTheme.spacingM)
                        .padding(.vertical, SaltTheme.spacingS)
                        .background(
                            viewModel.currentPreset == preset
                                ? SaltColors.accent
                                : SaltColors.surfaceElevated
                        )
                        .foregroundColor(
                            viewModel.currentPreset == preset
                                ? .white
                                : SaltColors.textSecondary
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, SaltTheme.spacingL)
        }
        .padding(.bottom, SaltTheme.spacingL)
    }

    @ViewBuilder
    private var bandSliders: some View {
        VStack(spacing: SaltTheme.spacingM) {
            HStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { index in
                    VStack(spacing: SaltTheme.spacingXS) {
                        Text(String(format: "+%.0f", viewModel.bands[safe: index]?.gain ?? 0))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(SaltColors.textTertiary)
                            .frame(height: 16)

                        EQSliderView(
                            value: Binding(
                                get: { viewModel.bands[safe: index]?.gain ?? 0 },
                                set: { viewModel.setBandGain(at: index, gain: $0) }
                            )
                        )
                        .frame(width: 30, height: 200)

                        Text(bandLabels[safe: index] ?? "")
                            .font(.system(size: 10))
                            .foregroundColor(SaltColors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, SaltTheme.spacingM)

            HStack {
                Text("Bass")
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textTertiary)

                Spacer()

                Text("Treble")
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textTertiary)
            }
            .padding(.horizontal, SaltTheme.spacingXL)
        }
    }

    @ViewBuilder
    private var disabledState: some View {
        VStack(spacing: SaltTheme.spacingL) {
            Spacer()

            Image(systemName: "speaker.slash")
                .font(.system(size: 48))
                .foregroundColor(SaltColors.textTertiary)

            Text("Equalizer is disabled")
                .font(SaltTypography.headline)
                .foregroundColor(SaltColors.textSecondary)

            Text("Enable the equalizer to customize your audio")
                .font(SaltTypography.caption1)
                .foregroundColor(SaltColors.textTertiary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(SaltTheme.spacingXL)
    }
}

struct EQSliderView: View {
    @Binding var value: Float

    private let minValue: Float = -12.0
    private let maxValue: Float = 12.0

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let normalizedValue = CGFloat((value - minValue) / (maxValue - minValue))
            let thumbY = height - (normalizedValue * height)

            ZStack {
                Capsule()
                    .fill(SaltColors.progressBackground)
                    .frame(width: 4)

                Capsule()
                    .fill(
                        value >= 0 ? SaltColors.accent : SaltColors.warning
                    )
                    .frame(width: 4, height: abs(thumbY - height / 2))
                    .position(x: geometry.size.width / 2, y: (thumbY + height / 2) / 2)

                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    .position(x: geometry.size.width / 2, y: thumbY)
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let newY = max(0, min(height, gesture.location.y))
                        let newValue = Float(1 - (newY / height)) * (maxValue - minValue) + minValue
                        value = max(minValue, min(maxValue, newValue))
                    }
            )
        }
    }
}

#Preview {
    EqualizerView()
}
