import Foundation
import AVFoundation

final class CrossfadePlayer {
    private weak var playerNode: AVAudioPlayerNode?
    private weak var eqNode: AVAudioUnitEQ?
    private weak var engine: AVAudioEngine?

    private var secondaryPlayerNode: AVAudioPlayerNode?
    private var crossfadeDuration: TimeInterval = 3.0
    private var isCrossfading = false

    init(playerNode: AVAudioPlayerNode, eqNode: AVAudioUnitEQ, engine: AVAudioEngine) {
        self.playerNode = playerNode
        self.eqNode = eqNode
        self.engine = engine

        setupSecondaryPlayer()
    }

    private func setupSecondaryPlayer() {
        guard let engine = engine else { return }
        secondaryPlayerNode = AVAudioPlayerNode()
        guard let secondary = secondaryPlayerNode else { return }

        engine.attach(secondary)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(secondary, to: eqNode!, format: format)
    }

    func crossfadeTo(song: Song, duration: TimeInterval = 3.0) {
        guard !isCrossfading,
              let primaryNode = playerNode,
              let secondaryNode = secondaryPlayerNode,
              let engine = engine else {
            loadAndPlay(song)
            return
        }

        isCrossfading = true
        crossfadeDuration = duration

        do {
            let url = URL(fileURLWithPath: song.filePath)
            let file = try AVAudioFile(forReading: url)
            let frameCount = AVAudioFrameCount(file.length)

            secondaryNode.volume = 0
            secondaryNode.scheduleFile(file, at: nil)

            if !engine.isRunning {
                try engine.start()
            }
            secondaryNode.play()

            let steps = 30
            let stepDuration = duration / Double(steps)
            let volumeStep = 1.0 / Float(steps)

            for i in 0..<steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) { [weak self] in
                    guard let self = self else { return }
                    primaryNode.volume = max(0, primaryNode.volume - volumeStep)
                    secondaryNode.volume = min(1.0, secondaryNode.volume + volumeStep)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                primaryNode.stop()
                self?.swapPlayers()
                self?.isCrossfading = false
            }
        } catch {
            print("Crossfade failed: \(error)")
            loadAndPlay(song)
        }
    }

    private func loadAndPlay(_ song: Song) {
        AudioEngine.shared.load(song: song)
        AudioEngine.shared.play()
    }

    private func swapPlayers() {
        guard let engine = engine,
              let primary = playerNode,
              let secondary = secondaryPlayerNode else { return }

        engine.disconnectNodeOutput(primary)
        engine.detach(primary)

        playerNode = secondary
        secondaryPlayerNode = AVAudioPlayerNode()
        guard let newSecondary = secondaryPlayerNode else { return }

        engine.attach(newSecondary)
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(newSecondary, to: eqNode!, format: format)

        primary.volume = 1.0
    }

    func setCrossfadeDuration(_ duration: TimeInterval) {
        crossfadeDuration = max(0.5, min(12.0, duration))
    }
}
