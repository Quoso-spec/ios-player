import Foundation

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var tracks: [Track] = []
    @Published var searchText = ""
    @Published var statistics = LibraryStatistics()
    @Published var message: String?
    @Published var isImporting = false

    private weak var environment: AppEnvironment?

    func bind(environment: AppEnvironment) {
        self.environment = environment
    }

    func refresh() async {
        guard let environment else { return }
        do {
            tracks = try await environment.libraryStore.tracks(sort: .title)
            statistics = try await environment.libraryStore.libraryStatistics()
            message = nil
        } catch {
            message = "曲库读取失败：\(error.localizedDescription)"
        }
    }

    func search() async {
        guard let environment else { return }
        do {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                tracks = try await environment.libraryStore.tracks(sort: .title)
            } else {
                tracks = try await environment.libraryStore.searchTracks(query: searchText)
            }
        } catch {
            message = "搜索失败：\(error.localizedDescription)"
        }
    }

    func importFiles() {
        Task {
            await importUsing { environment in
                try await environment.mediaImporter.importFiles()
            }
        }
    }

    func importFolder() {
        Task {
            await importUsing { environment in
                try await environment.mediaImporter.importFolder()
            }
        }
    }

    func rescan() {
        Task {
            guard let environment else { return }
            do {
                let report = try await environment.mediaImporter.rescanLibrary()
                message = "扫描完成：更新 \(report.updatedCount)，缺失 \(report.missingCount)，失败 \(report.failedCount)"
                await refresh()
            } catch {
                message = "扫描失败：\(error.localizedDescription)"
            }
        }
    }

    func play(track: Track) {
        guard let environment, let index = tracks.firstIndex(where: { $0.id == track.id }) else {
            return
        }
        do {
            try environment.playbackEngine.load(queue: tracks, startIndex: index)
            environment.playbackEngine.play()
            Task {
                try? await environment.libraryStore.recordPlayback(trackID: track.id, at: Date())
            }
        } catch {
            message = "播放失败：\(error.localizedDescription)"
        }
    }

    func toggleFavorite(track: Track) {
        Task {
            guard let environment else { return }
            do {
                try await environment.libraryStore.setFavorite(trackID: track.id, isFavorite: !track.isFavorite)
                await refresh()
            } catch {
                message = "收藏状态更新失败：\(error.localizedDescription)"
            }
        }
    }

    private func importUsing(_ importer: @escaping (AppEnvironment) async throws -> ImportBatch) async {
        guard let environment else { return }
        isImporting = true
        defer {
            isImporting = false
        }

        do {
            let batch = try await importer(environment)
            message = "导入 \(batch.importedTracks.count) 首，失败 \(batch.failedURLs.count) 个文件"
            await refresh()
        } catch MediaImporterError.cancelled {
            message = nil
        } catch {
            message = "导入失败：\(error.localizedDescription)"
        }
    }
}

