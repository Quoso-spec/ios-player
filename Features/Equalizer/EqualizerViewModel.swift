import Foundation
import Combine
import SwiftUI

@MainActor
final class EqualizerViewModel: ObservableObject {
    @Published var isEnabled: Bool = false {
        didSet {
            settings.equalizerEnabled = isEnabled
            audioEngine.equalizer.isEnabled = isEnabled
        }
    }

    @Published var bands: [EQBand] = []
    @Published var currentPreset: EQPreset = .flat {
        didSet {
            if currentPreset != .custom {
                settings.selectedEQPreset = currentPreset.rawValue
                audioEngine.equalizer.applyPreset(currentPreset)
                loadBands()
            }
        }
    }

    @Published var selectedPresetIndex: Int = 0

    private let audioEngine = AudioEngine.shared
    private let settings = SettingsStore.shared

    init() {
        isEnabled = settings.equalizerEnabled
        if let preset = EQPreset(rawValue: settings.selectedEQPreset) {
            currentPreset = preset
        }
        loadBands()
    }

    func loadBands() {
        bands = audioEngine.equalizer.bands
        if let index = EQPreset.allCases.firstIndex(where: { $0.rawValue == currentPreset.rawValue }) {
            selectedPresetIndex = index
        }
    }

    func setBandGain(at index: Int, gain: Float) {
        audioEngine.equalizer.setBandGain(at: index, gain: gain)
        bands[index].gain = gain
        currentPreset = .custom
    }

    func applyPreset(_ preset: EQPreset) {
        currentPreset = preset
        audioEngine.equalizer.applyPreset(preset)
        loadBands()
    }

    func reset() {
        currentPreset = .flat
        audioEngine.equalizer.reset()
        loadBands()
    }

    var presets: [EQPreset] {
        EQPreset.allCases
    }

    func bandLabel(at index: Int) -> String {
        guard index < bands.count else { return "" }
        return bands[index].label
    }
}
