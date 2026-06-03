import Foundation
import AVFoundation
import UIKit

actor ArtworkExtractor {
    static let shared = ArtworkExtractor()

    private init() {}

    func extractArtwork(from url: URL) async -> Data? {
        let fileExtension = url.pathExtension.lowercased()

        switch fileExtension {
        case "mp3":
            return await extractFromMP3(url: url)
        case "m4a", "aac", "alac":
            return await extractFromM4A(url: url)
        default:
            return await extractFromAVAsset(url: url)
        }
    }

    private func extractFromMP3(url: URL) async -> Data? {
        let asset = AVURLAsset(url: url)
        return await extractFromAsset(asset)
    }

    private func extractFromM4A(url: URL) async -> Data? {
        let asset = AVURLAsset(url: url)
        return await extractFromAsset(asset)
    }

    private func extractFromAVAsset(url: URL) async -> Data? {
        let asset = AVURLAsset(url: url)
        return await extractFromAsset(asset)
    }

    private func extractFromAsset(_ asset: AVAsset) async -> Data? {
        let metadata = asset.commonMetadata

        for item in metadata {
            if item.commonKey == .commonKeyArtwork {
                if let data = item.dataValue {
                    return resizeImageData(data, maxSize: 512)
                }
            }
        }

        let formats = [AVMetadataFormat.id3Metadata, AVMetadataFormat.iTunesMetadata]
        for format in formats {
            let formatMetadata = asset.metadata.filter { $0.commonKey == nil }
            for item in formatMetadata {
                if item.key as? String == "APIC" || String(describing: item.key).contains("Picture") {
                    if let data = item.dataValue {
                        return resizeImageData(data, maxSize: 512)
                    }
                }
            }
        }

        return nil
    }

    private func resizeImageData(_ data: Data, maxSize: CGFloat) -> Data? {
        guard let image = UIImage(data: data) else { return data }

        let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
        if scale >= 1.0 {
            return data
        }

        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage?.jpegData(compressionQuality: 0.8)
    }

    func saveArtworkToCache(_ data: Data, forSongId songId: String) async {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let artworkDir = cacheDir.appendingPathComponent("Artwork", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: artworkDir, withIntermediateDirectories: true)
            let fileURL = artworkDir.appendingPathComponent("\(songId).jpg")
            try data.write(to: fileURL)
        } catch {
            print("Failed to save artwork: \(error)")
        }
    }

    func loadArtworkFromCache(songId: String) async -> Data? {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cacheDir.appendingPathComponent("Artwork/\(songId).jpg")

        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

        do {
            return try Data(contentsOf: fileURL)
        } catch {
            return nil
        }
    }
}
