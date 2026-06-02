import SwiftUI

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            ZStack {
                Circle()
                    .fill(SaltGradient.accent)
                    .frame(width: 56, height: 56)
                    .shadow(color: SaltColors.primary.opacity(0.4), radius: 8, y: 4)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(FABButtonStyle())
    }
}

struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SmallFAB: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(SaltColors.surfaceElevated)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SaltColors.textPrimary)
            }
        }
        .buttonStyle(FABButtonStyle())
    }
}

#Preview {
    ZStack {
        SaltColors.background.ignoresSafeArea()

        VStack(spacing: 20) {
            FloatingActionButton(icon: "plus", action: {})
            SmallFAB(icon: "shuffle", action: {})
        }
    }
}
