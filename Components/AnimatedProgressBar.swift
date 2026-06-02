import SwiftUI

struct AnimatedProgressBar: View {
    @Binding var value: Double
    let onEditingChanged: (Bool) -> Void

    @State private var isDragging = false
    @GestureState private var dragState: CGFloat = 0

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(SaltColors.progressBackground)
                    .frame(height: trackHeight)

                Capsule()
                    .fill(SaltGradient.accent)
                    .frame(width: max(0, CGFloat(value) * width), height: trackHeight)
                    .animation(.linear(duration: 0.1), value: value)

                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    .offset(x: CGFloat(value) * width - thumbSize / 2)
                    .opacity(isDragging ? 1 : 0)
                    .animation(.easeInOut(duration: 0.15), value: isDragging)
            }
            .frame(height: max(trackHeight, thumbSize))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged(true)
                        }
                        let newValue = gesture.location.x / width
                        value = max(0, min(1, Double(newValue)))
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged(false)
                    }
            )
        }
        .frame(height: thumbSize)
    }
}

struct VolumeSliderView: View {
    @Binding var value: Float
    let icon: String

    var body: some View {
        HStack(spacing: SaltTheme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(SaltColors.textSecondary)
                .frame(width: 20)

            GeometryReader { geometry in
                let width = geometry.size.width

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(SaltColors.progressBackground)
                        .frame(height: 3)

                    Capsule()
                        .fill(SaltColors.textSecondary)
                        .frame(width: CGFloat(value) * width, height: 3)
                        .animation(.linear(duration: 0.1), value: value)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .offset(x: CGFloat(value) * width - 5)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let newValue = Float(gesture.location.x / width)
                            value = max(0, min(1, newValue))
                        }
                )
            }
            .frame(height: 10)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        AnimatedProgressBar(
            value: .constant(0.4),
            onEditingChanged: { _ in }
        )
        .frame(width: 300)

        VolumeSliderView(
            value: .constant(0.7),
            icon: "speaker.wave.2.fill"
        )
        .frame(width: 200)
    }
    .padding()
    .background(SaltColors.background)
}
