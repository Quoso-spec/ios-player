import Foundation

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var advancedAudioConfiguration = AdvancedAudioConfiguration(
        equalizerBands: [
            EqualizerBand(frequency: 60),
            EqualizerBand(frequency: 230),
            EqualizerBand(frequency: 910),
            EqualizerBand(frequency: 3600),
            EqualizerBand(frequency: 14000)
        ]
    )
}

