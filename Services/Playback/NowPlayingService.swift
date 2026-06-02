import AVFoundation
import MediaPlayer
import UIKit

@MainActor
public final class NowPlayingService {
    private weak var playbackEngine: (any PlaybackEngine)?

    public init() {}

    public func attach(to playbackEngine: any PlaybackEngine) {
        self.playbackEngine = playbackEngine
        configureRemoteCommands()
        update(track: playbackEngine.currentTrack, state: playbackEngine.state)
    }

    public func update(track: Track?, state: PlaybackState) {
        guard let track else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.displayTitle,
            MPMediaItemPropertyArtist: track.displayArtist,
            MPMediaItemPropertyAlbumTitle: track.displayAlbum,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: state.progress,
            MPMediaItemPropertyPlaybackDuration: max(state.duration, track.duration),
            MPNowPlayingInfoPropertyPlaybackRate: state.status == .playing ? 1.0 : 0.0
        ]

        if let artworkID = track.artworkID, let image = UIImage(named: artworkID) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.playbackEngine?.play()
            }
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.playbackEngine?.pause()
            }
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.playbackEngine?.skipNext()
            }
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.playbackEngine?.skipPrevious()
            }
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor in
                self?.playbackEngine?.seek(to: event.positionTime)
            }
            return .success
        }
    }
}
