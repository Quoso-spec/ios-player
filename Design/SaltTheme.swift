import SwiftUI

struct SaltTheme {
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXLarge: CGFloat = 24

    static let spacingXXS: CGFloat = 2
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32
    static let spacingXXXL: CGFloat = 48

    static let iconSizeSmall: CGFloat = 16
    static let iconSizeMedium: CGFloat = 24
    static let iconSizeLarge: CGFloat = 32
    static let iconSizeXLarge: CGFloat = 48

    static let albumCoverSizeSmall: CGFloat = 48
    static let albumCoverSizeMedium: CGFloat = 64
    static let albumCoverSizeLarge: CGFloat = 120
    static let albumCoverSizeXLarge: CGFloat = 280

    static let miniPlayerHeight: CGFloat = 64
    static let tabBarHeight: CGFloat = 49

    static let blurStyle: UIBlurEffect.Style = .systemThinMaterialDark
}

struct SaltGradient {
    static let accent = LinearGradient(
        colors: [SaltColors.gradientStart, SaltColors.gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surface = LinearGradient(
        colors: [SaltColors.surface, SaltColors.surfaceElevated],
        startPoint: .top,
        endPoint: .bottom
    )

    static let text = LinearGradient(
        colors: [SaltColors.textPrimary, SaltColors.textSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )
}

struct SaltShadow {
    static let small = (color: Color.black.opacity(0.3), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    static let medium = (color: Color.black.opacity(0.4), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    static let large = (color: Color.black.opacity(0.5), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
}
