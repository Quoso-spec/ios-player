import Foundation
import AVFoundation

final class GaplessPlayer {
    private weak var audioPlayerNode: AVAudioPlayerNode?
    private weak var engine: AVAudioEngine?

    init(audioPlayerNode: AVAudioPlayerNode, engine: AVAudioEngine) {
        self.audioPlayerNode = audioPlayerNode
        self.engine = engine
    }

    func scheduleNextSong(_ song: Song, prepareTime: TimeInterval = 0.5) {
        guard let playerNode = audioPlayerNode,
              let engine = engine,
              let currentNodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: currentNodeTime) else {
            return
        }

        let sampleRate = playerNode.lastRenderTime.map { playerNode.playerTime(forNodeTime: $0)?.sampleRate } ?? 44100
        let remainingSamples = AVAudioFrameCount(
            Double(playerNode.lastRenderTime.map { playerNode.playerTime(forNodeTime: $0)?.sampleTime ?? 0 } ?? 0)
        )

        guard remainingSamples > 0 else {
            scheduleSongImmediately(song)
            return
        }

        let scheduleTime = AVAudioTime(
            sampleTime: AVAudioFramePosition(sampleRate ?? 44100) * AVAudioFramePosition(prepareTime),
            atRate: sampleRate ?? 44100
        )

        do {
            let url = URL(fileURLWithPath: song.filePath)
            let file = try AVAudioFile(forReading: url)

            if engine.isRunning {
                playerNode.scheduleFile(file, at: scheduleTime) { [weak self] in
                    DispatchQueue.main.async {
                        self?.handleSongFinished()
                    }
                }
            }
        } catch {
            print("Failed to schedule next song for gapless playback: \(error)")
        }
    }

    private func scheduleSongImmediately(_ song: Song) {
        guard let playerNode = audioPlayerNode else { return }

        do {
            let url = URL(fileURLWithPath: song.filePath)
            let file = try AVAudioFile(forReading: url)
            playerNode.scheduleFile(file, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    self?.handleSongFinished()
                }
            }
        } catch {
            print("Failed to schedule song immediately: \(error)")
        }
    }

    private func handleSongFinished() {
        PlaybackQueueManager.shared.next()
    }

    func handlePlaybackCompletion(queue: PlaybackQueueManager) {
    }
}
