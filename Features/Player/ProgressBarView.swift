import SwiftUI

struct ProgressBarView: View {
    @Binding var currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void

    @State private var isDragging = false
    @State private var dragProgress: Double = 0

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return isDragging ? dragProgress : (currentTime / duration)
    }

    var body: some View {
        VStack(spacing: SaltTheme.spacingS) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(SaltColors.progressBackground)
                        .frame(height: 4)

                    Capsule()
                        .fill(SaltGradient.accent)
                        .frame(width: max(0, geometry.size.width * progress), height: 4)

                    Circle()
                        .fill(Color.white)
                        .frame(width: isDragging ? 16 : 12, height: isDragging ? 16 : 12)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        .offset(x: max(0, min(geometry.size.width - 12, geometry.size.width * progress - 6)))
                        .animation(.easeInOut(duration: 0.1), value: isDragging)
                }
                .frame(height: 16)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isDragging = true
                            let newProgress = gesture.location.x / geometry.size.width
                            dragProgress = max(0, min(1, newProgress))
                        }
                        .onEnded { gesture in
                            isDragging = false
                            let finalProgress = gesture.location.x / geometry.size.width
                            let clampedProgress = max(0, min(1, finalProgress))
                            onSeek(duration * clampedProgress)
                        }
                )
            }
            .frame(height: 16)

            HStack {
                Text(formatTime(isDragging ? (dragProgress * duration) : currentTime))
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textSecondary)
                    .monospacedDigit()

                Spacer()

                Text(formatTime(duration))
                    .font(SaltTypography.caption1)
                    .foregroundColor(SaltColors.textSecondary)
                    .monospacedDigit()
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack {
        ProgressBarView(
            currentTime: .constant(60),
            duration: 180,
            onSeek: { _ in }
        )
    }
    .padding()
    .background(SaltColors.background)
}
