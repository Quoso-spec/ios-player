import Foundation
import AVFoundation
import ID3TagEditor

final class MetadataReader {
    static let shared = MetadataReader()

    private let id3TagEditor = ID3TagEditor()

    private init() {}

    func readMetadata(from url: URL) async -> Song {
        let fileExtension = url.pathExtension.lowercased()

        var song = Song(
            title: url.deletingPathExtension().lastPathComponent,
            filePath: url.path
        )

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            song.fileSize = attributes[.size] as? Int64 ?? 0
        } catch {
            print("Failed to get file size: \(error)")
        }

        switch fileExtension {
        case "mp3":
            song = await readMP3Metadata(from: url, song: song)
        case "m4a", "aac", "alac":
            song = await readM4AMetadata(from: url, song: song)
        case "flac":
            song = await readFLACMetadata(from: url, song: song)
        default:
            song = await readGenericMetadata(from: url, song: song)
        }

        return song
    }

    private func readMP3Metadata(from url: URL, song: Song) async -> Song {
        var updatedSong = song

        do {
            if let id3Tag = try id3TagEditor.read(from: url.path) {
                if let titleFrame = (id3Tag.frames[.title] as? ID3FrameWithStringContent) {
                    updatedSong.title = titleFrame.content
                }
                if let artistFrame = (id3Tag.frames[.artist] as? ID3FrameWithStringContent) {
                    updatedSong.artist = artistFrame.content
                }
                if let albumFrame = (id3Tag.frames[.album] as? ID3FrameWithStringContent) {
                    updatedSong.album = albumFrame.content
                }
                if let albumArtistFrame = (id3Tag.frames[.albumArtist] as? ID3FrameWithStringContent) {
                    updatedSong.albumArtist = albumArtistFrame.content
                }
                if let yearFrame = (id3Tag.frames[.recordingYear] as? ID3FrameWithIntegerContent) {
                    updatedSong.year = yearFrame.value ?? 0
                }
                if let genreFrame = (id3Tag.frames[.genre] as? ID3FrameWithStringContent) {
                    updatedSong.genre = genreFrame.content
                }
                if let trackFrame = (id3Tag.frames[.trackPosition] as? ID3FramePartOfTotal) {
                    updatedSong.trackNumber = trackFrame.part
                }
                if let discFrame = (id3Tag.frames[.discPosition] as? ID3FramePartOfTotal) {
                    updatedSong.discNumber = discFrame.part
                }
                if let durationFrame = (id3Tag.frames[ID3FrameName.recordingLength] as? ID3FrameWithIntegerContent) {
                    updatedSong.duration = TimeInterval(durationFrame.value ?? 0)
                }
                if let attachedPicture = (id3Tag.frames[.attachedPicture(.frontCover)] as? ID3FrameAttachedPicture) {
                    updatedSong.artworkData = attachedPicture.picture
                } else if let attachedPicture = (id3Tag.frames[.attachedPicture(.other)] as? ID3FrameAttachedPicture) {
                    updatedSong.artworkData = attachedPicture.picture
                }
            }
        } catch {
            print("Failed to read MP3 metadata: \(error)")
            updatedSong = await readGenericMetadata(from: url, song: updatedSong)
        }

        if updatedSong.artworkData == nil {
            updatedSong.artworkData = await ArtworkExtractor.shared.extractArtwork(from: url)
        }

        return updatedSong
    }

    private func readM4AMetadata(from url: URL, song: Song) async -> Song {
        var updatedSong = song

        let asset = AVURLAsset(url: url)
        let metadata = asset.commonMetadata

        for item in metadata {
            guard let key = item.commonKey else { continue }

            switch key {
            case .commonKeyTitle:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.title = value
                }
            case .commonKeyArtist:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.artist = value
                }
            case .commonKeyAlbumName:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.album = value
                }
            case .commonKeyArtwork:
                if let data = item.dataValue {
                    updatedSong.artworkData = data
                }
            default:
                break
            }
        }

        updatedSong.duration = CMTimeGetSeconds(asset.duration)
        if updatedSong.duration.isNaN || updatedSong.duration.isInfinite {
            updatedSong.duration = 0
        }

        if updatedSong.artworkData == nil {
            updatedSong.artworkData = await ArtworkExtractor.shared.extractArtwork(from: url)
        }

        return updatedSong
    }

    private func readFLACMetadata(from url: URL, song: Song) async -> Song {
        var updatedSong = song

        let asset = AVURLAsset(url: url)
        let metadata = asset.commonMetadata

        for item in metadata {
            guard let key = item.commonKey else { continue }

            switch key {
            case .commonKeyTitle:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.title = value
                }
            case .commonKeyArtist:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.artist = value
                }
            case .commonKeyAlbumName:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.album = value
                }
            case .commonKeyArtwork:
                if let data = item.dataValue {
                    updatedSong.artworkData = data
                }
            default:
                break
            }
        }

        updatedSong.duration = CMTimeGetSeconds(asset.duration)
        if updatedSong.duration.isNaN || updatedSong.duration.isInfinite {
            updatedSong.duration = 0
        }

        if updatedSong.artworkData == nil {
            updatedSong.artworkData = await ArtworkExtractor.shared.extractArtwork(from: url)
        }

        return updatedSong
    }

    private func readGenericMetadata(from url: URL, song: Song) async -> Song {
        var updatedSong = song

        let asset = AVURLAsset(url: url)
        let metadata = asset.commonMetadata

        for item in metadata {
            guard let key = item.commonKey else { continue }

            switch key {
            case .commonKeyTitle:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.title = value
                }
            case .commonKeyArtist:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.artist = value
                }
            case .commonKeyAlbumName:
                if let value = item.stringValue, !value.isEmpty {
                    updatedSong.album = value
                }
            case .commonKeyArtwork:
                if let data = item.dataValue {
                    updatedSong.artworkData = data
                }
            default:
                break
            }
        }

        updatedSong.duration = CMTimeGetSeconds(asset.duration)
        if updatedSong.duration.isNaN || updatedSong.duration.isInfinite {
            updatedSong.duration = 0
        }

        return updatedSong
    }

    func readDurationOnly(from url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        return duration.isNaN || duration.isInfinite ? 0 : duration
    }
}
