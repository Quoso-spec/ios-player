import SwiftUI

struct SaltTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    static let lyricsCurrent = Font.system(size: 24, weight: .bold, design: .default)
    static let lyricsNormal = Font.system(size: 20, weight: .medium, design: .default)
    static let lyricsInactive = Font.system(size: 18, weight: .regular, design: .default)

    static let counter = Font.system(size: 12, weight: .medium, design: .monospaced)
}

extension View {
    func saltLargeTitle() -> some View {
        self.font(SaltTypography.largeTitle)
            .foregroundColor(SaltColors.textPrimary)
    }

    func saltTitle1() -> some View {
        self.font(SaltTypography.title1)
            .foregroundColor(SaltColors.textPrimary)
    }

    func saltTitle2() -> some View {
        self.font(SaltTypography.title2)
            .foregroundColor(SaltColors.textPrimary)
    }

    func saltTitle3() -> some View {
        self.font(SaltTypography.title3)
            .foregroundColor(SaltColors.textPrimary)
    }

    func saltHeadline() -> some View {
        self.font(SaltTypography.headline)
            .foregroundColor(SaltColors.textPrimary)
    }

    func saltBody() -> some View {
        self.font(SaltTypography.body)
            .foregroundColor(SaltColors.textPrimary)
    }

    func saltSecondary() -> some View {
        self.font(SaltTypography.subheadline)
            .foregroundColor(SaltColors.textSecondary)
    }

    func saltCaption() -> some View {
        self.font(SaltTypography.caption1)
            .foregroundColor(SaltColors.textTertiary)
    }
}
