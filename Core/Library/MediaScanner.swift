import Foundation

actor MediaScanner {
    static let shared = MediaScanner()

    private init() {}

    func scanForAudioFiles(in directory: URL) async -> [URL] {
        var audioFiles: [URL] = []

        guard FileManager.default.fileExists(atPath: directory.path) else {
            return []
        }

        let shouldStopAccessing = directory.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                directory.stopAccessingSecurityScopedResource()
            }
        }

        do {
            audioFiles = try scanDirectory(directory, maxDepth: 10)
        } catch {
            print("Failed to scan directory: \(error)")
        }

        return audioFiles
    }

    private func scanDirectory(_ url: URL, maxDepth: Int, currentDepth: Int = 0) throws -> [URL] {
        var audioFiles: [URL] = []

        guard currentDepth < maxDepth else { return [] }

        let contents = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey, .nameKey],
            options: [.skipsHiddenFiles]
        )

        for itemURL in contents {
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDirectory)

            if isDirectory.boolValue {
                let subFiles = try scanDirectory(itemURL, maxDepth: maxDepth, currentDepth: currentDepth + 1)
                audioFiles.append(contentsOf: subFiles)
            } else {
                let ext = itemURL.pathExtension.lowercased()
                if Song.supportedExtensions.contains(ext) {
                    audioFiles.append(itemURL)
                }
            }
        }

        return audioFiles
    }

    func scanWithProgress(in directory: URL, progressHandler: @escaping (Int, Int) -> Void) async throws -> [URL] {
        var audioFiles: [URL] = []

        guard FileManager.default.fileExists(atPath: directory.path) else {
            return []
        }

        let shouldStopAccessing = directory.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                directory.stopAccessingSecurityScopedResource()
            }
        }

        let allFiles = try gatherAllFiles(in: directory)
        let total = allFiles.count

        for (index, fileURL) in allFiles.enumerated() {
            let ext = fileURL.pathExtension.lowercased()
            if Song.supportedExtensions.contains(ext) {
                audioFiles.append(fileURL)
            }

            if index % 50 == 0 {
                progressHandler(index + 1, total)
                try await Task.sleep(nanoseconds: 1_000_000)
            }
        }

        progressHandler(total, total)
        return audioFiles
    }

    private func gatherAllFiles(in directory: URL) throws -> [URL] {
        var files: [URL] = []

        let contents = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        for itemURL in contents {
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDirectory)

            if isDirectory.boolValue {
                let subFiles = try gatherAllFiles(in: itemURL)
                files.append(contentsOf: subFiles)
            } else {
                files.append(itemURL)
            }
        }

        return files
    }
}
