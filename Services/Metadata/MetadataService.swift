import AVFoundation
import Foundation

public protocol MetadataService {
    func metadata(for url: URL) async throws -> TrackMetadata
}

public final class AVAssetMetadataService: MetadataService {
    public init() {}

    public func metadata(for url: URL) async throws -> TrackMetadata {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        let commonMetadata = try await asset.load(.commonMetadata)
        let tracks = try await asset.load(.tracks)
        let audioTrack = tracks.first { $0.mediaType == .audio }

        let bitrate: Float?
        let formatDescriptions: [CMFormatDescription]?
        if let audioTrack {
            bitrate = try await audioTrack.load(.estimatedDataRate)
            formatDescriptions = try await audioTrack.load(.formatDescriptions)
        } else {
            bitrate = nil
            formatDescriptions = nil
        }

        let sampleRate = Self.sampleRate(from: formatDescriptions)

        return TrackMetadata(
            title: Self.stringValue(for: .commonIdentifierTitle, in: commonMetadata),
            artist: Self.stringValue(for: .commonIdentifierArtist, in: commonMetadata),
            album: Self.stringValue(for: .commonIdentifierAlbumName, in: commonMetadata),
            albumArtist: Self.stringValue(for: .iTunesMetadataAlbumArtist, in: commonMetadata),
            duration: duration.seconds.isFinite ? duration.seconds : 0,
            format: url.pathExtension.lowercased(),
            bitrate: bitrate.map { Int($0) },
            sampleRate: sampleRate,
            artworkData: Self.dataValue(for: .commonIdentifierArtwork, in: commonMetadata)
        )
    }

    private static func stringValue(for identifier: AVMetadataIdentifier, in metadata: [AVMetadataItem]) -> String? {
        AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: identifier)
            .compactMap(\.stringValue)
            .first
    }

    private static func dataValue(for identifier: AVMetadataIdentifier, in metadata: [AVMetadataItem]) -> Data? {
        AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: identifier)
            .compactMap(\.dataValue)
            .first
    }

    private static func sampleRate(from descriptions: [CMFormatDescription]?) -> Int? {
        guard
            let description = descriptions?.first,
            let streamDescription = CMAudioFormatDescriptionGetStreamBasicDescription(description)
        else {
            return nil
        }
        return Int(streamDescription.pointee.mSampleRate)
    }
}
