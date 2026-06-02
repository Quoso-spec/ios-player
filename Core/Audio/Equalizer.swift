import Foundation
import AVFoundation

final class Equalizer: ObservableObject {
    private let node: AVAudioUnitEQ

    @Published var bands: [EQBand] = []
    @Published var isEnabled: Bool = true {
        didSet { updateEnabled() }
    }
    @Published var currentPreset: EQPreset = .flat

    let bandCount = 10
    private let defaultFrequencies: [Float] = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]

    init(node: AVAudioUnitEQ) {
        self.node = node
        loadBands()
    }

    private func loadBands() {
        bands = (0..<bandCount).map { index in
            let band = node.bands[index]
            return EQBand(
                frequency: defaultFrequencies[index],
                gain: band.gain,
                bandwidth: band.bandwidth
            )
        }
    }

    private func updateEnabled() {
        for band in node.bands {
            band.bypass = !isEnabled
        }
    }

    func setBandGain(at index: Int, gain: Float) {
        guard index >= 0 && index < bandCount else { return }
        node.bands[index].gain = gain
        node.bands[index].bypass = false
        bands[index].gain = gain
        currentPreset = .custom
    }

    func applyPreset(_ preset: EQPreset) {
        currentPreset = preset
        for (index, presetBand) in preset.bands.enumerated() {
            guard index < bandCount else { break }
            setBandGain(at: index, gain: presetBand)
        }
    }

    func reset() {
        applyPreset(.flat)
    }

    func formatFrequency(_ freq: Float) -> String {
        if freq >= 1000 {
            return String(format: "%.0fk", freq / 1000)
        } else {
            return String(format: "%.0f", freq)
        }
    }
}

struct EQBand: Identifiable {
    let id = UUID()
    var frequency: Float
    var gain: Float
    var bandwidth: Float

    var label: String {
        if frequency >= 1000 {
            return String(format: "%.0fk", frequency / 1000)
        } else {
            return String(format: "%.0f", frequency)
        }
    }
}

enum EQPreset: String, CaseIterable, Identifiable {
    case flat = "Flat"
    case pop = "Pop"
    case rock = "Rock"
    case jazz = "Jazz"
    case classical = "Classical"
    case dance = "Dance"
    case hiphop = "Hip-Hop"
    case electronic = "Electronic"
    case vocal = "Vocal"
    case bass = "Bass"
    case treble = "Treble"
    case custom = "Custom"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .flat: return "equal"
        case .pop: return "music.note"
        case .rock: return "guitars"
        case .jazz: return "pianokeys"
        case .classical: return "building.columns"
        case .dance: return "waveform.path"
        case .hiphop: return "mic"
        case .electronic: return "waveform"
        case .vocal: return "person.wave.2"
        case .bass: return "speaker.wave.3"
        case .treble: return "speaker.badge.exclamationmark"
        case .custom: return "slider.horizontal.3"
        }
    }

    var bands: [Float] {
        switch self {
        case .flat:
            return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        case .pop:
            return [-1, 1, 3, 4, 3, 0, -1, -1, 1, 1]
        case .rock:
            return [4, 3, 1, 0, -1, 0, 2, 3, 4, 4]
        case .jazz:
            return [2, 0, 1, 2, -1, -1, 0, 1, 2, 3]
        case .classical:
            return [3, 2, 1, 1, 0, 0, 1, 2, 3, 3]
        case .dance:
            return [5, 4, 2, 0, -1, 2, 3, 4, 4, 4]
        case .hiphop:
            return [4, 3, 1, 2, -1, 0, 2, 0, 1, 2]
        case .electronic:
            return [4, 3, 1, 0, -2, 2, 1, 2, 4, 4]
        case .vocal:
            return [-2, -1, 0, 2, 4, 4, 3, 1, 0, -1]
        case .bass:
            return [6, 5, 4, 2, 0, 0, 0, 0, 0, 0]
        case .treble:
            return [0, 0, 0, 0, 0, 1, 2, 3, 5, 6]
        case .custom:
            return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        }
    }
}
