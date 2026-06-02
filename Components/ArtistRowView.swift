import SwiftUI

struct ArtistRowView: View {
    let artist: Artist
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: SaltTheme.spacingM) {
            ArtistAvatarView(artist: artist, size: SaltTheme.albumCoverSizeMedium)

            VStack(alignment: .leading, spacing: SaltTheme.spacingXXS) {
                Text(artist.name)
                    .font(SaltTypography.headline)
                    .foregroundColor(SaltColors.textPrimary)
                    .lineLimit(1)

                Text("\(artist.albumCount) albums - \(artist.songCount) songs")
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, SaltTheme.spacingS)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct ArtistAvatarView: View {
    let artist: Artist
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(SaltColors.surfaceElevated)

            if let artworkData = artist.artworkData,
               let uiImage = UIImage(data: artworkData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(SaltColors.textTertiary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

#Preview {
    VStack {
        ArtistRowView(
            artist: Artist(name: "Test Artist", albumIds: ["1"], songIds: ["1", "2", "3"]),
            onTap: {}
        )

        ArtistRowView(
            artist: Artist(name: "Another Artist", albumIds: ["2"], songIds: ["4", "5"]),
            onTap: {}
        )
    }
    .padding()
    .background(SaltColors.background)
}
