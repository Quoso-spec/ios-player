import Foundation
import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = LibraryViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                libraryHeader
                if let message = viewModel.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(environment.theme.palette.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                List {
                    ForEach(viewModel.tracks) { track in
                        TrackRow(track: track)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.play(track: track)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    viewModel.toggleFavorite(track: track)
                                } label: {
                                    Label(track.isFavorite ? "取消收藏" : "收藏", systemImage: "heart")
                                }
                                .tint(environment.theme.palette.accent)
                            }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if viewModel.tracks.isEmpty {
                        ContentUnavailableView("暂无歌曲", systemImage: "music.note", description: Text("从文件或文件夹导入本地音乐"))
                    }
                }
            }
            .navigationTitle("椒盐音乐")
            .searchable(text: $viewModel.searchText, prompt: "搜索歌曲、艺人、专辑")
            .onChange(of: viewModel.searchText) {
                Task {
                    await viewModel.search()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        viewModel.importFiles()
                    } label: {
                        Image(systemName: "doc.badge.plus")
                    }
                    .help("导入文件")

                    Button {
                        viewModel.importFolder()
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                    .help("导入文件夹")

                    Button {
                        viewModel.rescan()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .help("重新扫描")
                }
            }
            .task {
                viewModel.bind(environment: environment)
                await viewModel.refresh()
            }
        }
    }

    private var libraryHeader: some View {
        HStack(spacing: 14) {
            statistic("歌曲", value: viewModel.statistics.trackCount)
            statistic("收藏", value: viewModel.statistics.favoriteCount)
            statistic("列表", value: viewModel.statistics.playlistCount)
            Spacer()
            if viewModel.isImporting {
                ProgressView()
            }
        }
        .padding()
        .background(environment.theme.palette.surface)
    }

    private func statistic(_ title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.headline)
                .foregroundStyle(environment.theme.palette.primaryText)
            Text(title)
                .font(.caption)
                .foregroundStyle(environment.theme.palette.secondaryText)
        }
        .frame(minWidth: 52, alignment: .leading)
    }
}

private struct TrackRow: View {
    let track: Track

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(.quaternary)
                Image(systemName: "music.note")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(track.displayTitle)
                        .font(.body)
                        .lineLimit(1)
                    if track.isMissing {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }
                    if track.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                    }
                }
                Text("\(track.displayArtist) · \(track.displayAlbum)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(Self.durationFormatter.string(from: track.duration) ?? "--:--")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
}
