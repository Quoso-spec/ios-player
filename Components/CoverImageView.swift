import SwiftUI

struct CoverImageView: View {
    let data: Data?
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusSmall)
                .fill(SaltColors.surfaceElevated)

            if let data = data,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(SaltColors.textTertiary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusSmall))
    }
}

struct CoverImageAsyncView: View {
    let artworkData: Data?
    let size: CGFloat
    let cornerRadius: CGFloat

    @State private var image: UIImage?
    @State private var isLoading = true

    init(data: Data?, size: CGFloat, cornerRadius: CGFloat = SaltTheme.cornerRadiusSmall) {
        self.artworkData = data
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(SaltColors.surfaceElevated)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
                    .tint(SaltColors.textTertiary)
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(SaltColors.textTertiary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let data = artworkData else {
            isLoading = false
            return
        }

        Task {
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = uiImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        CoverImageView(data: nil, size: 64)
        CoverImageAsyncView(data: nil, size: 64)
    }
    .padding()
    .background(SaltColors.background)
}
