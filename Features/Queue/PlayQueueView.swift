import SwiftUI

struct PlayQueueView: View {
    @StateObject private var viewModel = QueueViewModel()
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isEmpty {
                    emptyState
                } else {
                    queueList
                }
            }
            .background(SaltColors.background)
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(SaltColors.accent)
                }

                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.isEmpty {
                        Button("Clear") { viewModel.clearQueue() }
                            .foregroundColor(SaltColors.error)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: SaltTheme.spacingL) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(SaltColors.textTertiary)

            Text("Queue is empty")
                .font(SaltTypography.headline)
                .foregroundColor(SaltColors.textSecondary)

            Text("Add songs to your queue")
                .font(SaltTypography.subheadline)
                .foregroundColor(SaltColors.textTertiary)

            Spacer()
        }
    }

    @ViewBuilder
    private var queueList: some View {
        List {
            Section {
                ForEach(Array(viewModel.queue.originalOrder.enumerated()), id: \.element.id) { index, song in
                    QueueRowView(
                        song: song,
                        isCurrentSong: index == viewModel.currentIndex,
                        onTap: { viewModel.playAt(index: index) }
                    )
                    .listRowBackground(
                        index == viewModel.currentIndex ? SaltColors.surfaceElevated : SaltColors.background
                    )
                }
                .onDelete { offsets in
                    viewModel.removeAt(offsets: offsets)
                }
                .onMove { source, destination in
                    viewModel.move(from: source, to: destination)
                }
            } header: {
                HStack {
                    Text("\(viewModel.songCount) songs")
                        .font(SaltTypography.caption1)
                        .foregroundColor(SaltColors.textSecondary)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, .constant(.active))
    }
}

struct QueueRowView: View {
    let song: Song
    let isCurrentSong: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: SaltTheme.spacingM) {
            CoverImageView(
                data: song.artworkData,
                size: 48
            )

            VStack(alignment: .leading, spacing: SaltTheme.spacingXXS) {
                Text(song.title)
                    .font(SaltTypography.subheadline)
                    .foregroundColor(isCurrentSong ? SaltColors.accent : SaltColors.textPrimary)
                    .lineLimit(1)

                Text(song.artist)
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if isCurrentSong {
                Image(systemName: "waveform")
                    .font(.system(size: 14))
                    .foregroundColor(SaltColors.accent)
                    .symbolEffect(.variableColor.iterative)
            }

            Text(song.formattedDuration)
                .font(SaltTypography.caption1)
                .foregroundColor(SaltColors.textTertiary)
        }
        .padding(.vertical, SaltTheme.spacingXS)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    PlayQueueView()
        .environmentObject(PlayerViewModel())
}
