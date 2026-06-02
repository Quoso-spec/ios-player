import Foundation

extension URL {
    func saveSecurityBookmark() -> Data? {
        guard startAccessingSecurityScopedResource() else { return nil }
        defer { stopAccessingSecurityScopedResource() }

        do {
            let bookmarkData = try bookmarkData(
                options: .minimalBookmark,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            return bookmarkData
        } catch {
            print("Failed to create security bookmark: \(error)")
            return nil
        }
    }

    static func resolveSecurityBookmark(_ bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                print("Security bookmark is stale and may need to be recreated")
            }

            return url
        } catch {
            print("Failed to resolve security bookmark: \(error)")
            return nil
        }
    }

    static func resolveAndAccess(_ bookmarkData: Data) -> URL? {
        guard let url = resolveSecurityBookmark(bookmarkData) else { return nil }

        if url.startAccessingSecurityScopedResource() {
            return url
        }

        return nil
    }

    var isAudioFile: Bool {
        let audioExtensions = ["mp3", "m4a", "aac", "flac", "wav", "aiff", "alac", "ogg", "opus"]
        return audioExtensions.contains(pathExtension.lowercased())
    }

    var isLrcFile: Bool {
        pathExtension.lowercased() == "lrc" || pathExtension.lowercased() == "txt"
    }
}
