import SwiftUI

struct AlbumCardView: View {
    let album: Album
    let size: CGFloat
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SaltTheme.spacingS) {
            CoverImageView(
                data: album.artworkData,
                size: size
            )
            .clipShape(RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusMedium))

            Text(album.name)
                .font(SaltTypography.subheadline)
                .foregroundColor(SaltColors.textPrimary)
                .lineLimit(1)

            Text(album.artist)
                .font(SaltTypography.caption1)
                .foregroundColor(SaltColors.textSecondary)
                .lineLimit(1)
        }
        .frame(width: size)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct AlbumRowView: View {
    let album: Album
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: SaltTheme.spacingM) {
            CoverImageView(
                data: album.artworkData,
                size: SaltTheme.albumCoverSizeMedium
            )
            .clipShape(RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusSmall))

            VStack(alignment: .leading, spacing: SaltTheme.spacingXXS) {
                Text(album.name)
                    .font(SaltTypography.headline)
                    .foregroundColor(SaltColors.textPrimary)
                    .lineLimit(1)

                Text(album.artist)
                    .font(SaltTypography.subheadline)
                    .foregroundColor(SaltColors.textSecondary)
                    .lineLimit(1)

                Text("\(album.songCount) songs")
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textTertiary)
            }

            Spacer()
        }
        .padding(.vertical, SaltTheme.spacingS)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct AlbumGridView: View {
    let albums: [Album]
    let onAlbumTap: (Album) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 180), spacing: SaltTheme.spacingL)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: SaltTheme.spacingL) {
            ForEach(albums) { album in
                AlbumCardView(album: album, size: 150) {
                    onAlbumTap(album)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        AlbumGridView(
            albums: [
                Album(name: "Test Album", artist: "Test Artist"),
                Album(name: "Another Album", artist: "Another Artist")
            ],
            onAlbumTap: { _ in }
        )
    }
    .background(SaltColors.background)
}
