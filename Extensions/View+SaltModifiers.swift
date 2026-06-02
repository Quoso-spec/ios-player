import SwiftUI

extension View {
    func saltCard() -> some View {
        self
            .background(SaltColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusMedium))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }

    func saltElevatedCard() -> some View {
        self
            .background(SaltColors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: SaltTheme.cornerRadiusMedium))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }

    func saltGradientBackground() -> some View {
        self.background(SaltGradient.accent)
    }

    func saltIconStyle(color: Color = SaltColors.accent) -> some View {
        self
            .foregroundColor(color)
            .frame(width: 40, height: 40)
            .background(color.opacity(0.15))
            .clipShape(Circle())
    }

    func saltButtonStyle() -> some View {
        self
            .font(SaltTypography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, SaltTheme.spacingXL)
            .padding(.vertical, SaltTheme.spacingM)
            .background(SaltGradient.accent)
            .clipShape(Capsule())
    }

    func saltSecondaryButtonStyle() -> some View {
        self
            .font(SaltTypography.headline)
            .foregroundColor(SaltColors.accent)
            .padding(.horizontal, SaltTheme.spacingXL)
            .padding(.vertical, SaltTheme.spacingM)
            .background(SaltColors.surfaceElevated)
            .clipShape(Capsule())
    }

    func saltDivider() -> some View {
        Divider()
            .background(SaltColors.divider)
            .padding(.vertical, SaltTheme.spacingS)
    }

    func saltListRow() -> some View {
        self
            .listRowBackground(SaltColors.background)
            .listRowSeparatorTint(SaltColors.divider)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.2),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
