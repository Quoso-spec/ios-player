import Foundation
import SwiftUI

@MainActor
public final class SaltTheme: ThemeProviding {
    @Published public var variant: SaltThemeVariant = .dusk
    @Published public var playerBackgroundStyle: PlayerBackgroundStyle = .fluidGradient

    public init() {}

    public var typography: SaltTypographyScale {
        SaltTypographyScale(titleSize: 24, bodySize: 16, captionSize: 12)
    }

    public var palette: SaltColorPalette {
        switch variant {
        case .dusk:
            return SaltColorPalette(
                background: Color(red: 0.08, green: 0.09, blue: 0.11),
                surface: Color(red: 0.13, green: 0.14, blue: 0.17),
                elevatedSurface: Color(red: 0.18, green: 0.18, blue: 0.22),
                primaryText: .white,
                secondaryText: Color.white.opacity(0.64),
                accent: Color(red: 0.95, green: 0.35, blue: 0.45),
                warmAccent: Color(red: 1.00, green: 0.60, blue: 0.36),
                coolAccent: Color(red: 0.35, green: 0.72, blue: 0.95)
            )
        case .light:
            return SaltColorPalette(
                background: Color(red: 0.96, green: 0.97, blue: 0.98),
                surface: .white,
                elevatedSurface: Color(red: 0.91, green: 0.93, blue: 0.95),
                primaryText: Color(red: 0.08, green: 0.09, blue: 0.11),
                secondaryText: Color(red: 0.36, green: 0.39, blue: 0.43),
                accent: Color(red: 0.86, green: 0.20, blue: 0.31),
                warmAccent: Color(red: 0.95, green: 0.48, blue: 0.22),
                coolAccent: Color(red: 0.10, green: 0.52, blue: 0.78)
            )
        case .midnight:
            return SaltColorPalette(
                background: Color(red: 0.04, green: 0.05, blue: 0.07),
                surface: Color(red: 0.08, green: 0.10, blue: 0.13),
                elevatedSurface: Color(red: 0.12, green: 0.15, blue: 0.19),
                primaryText: .white,
                secondaryText: Color.white.opacity(0.58),
                accent: Color(red: 0.40, green: 0.72, blue: 0.94),
                warmAccent: Color(red: 0.94, green: 0.62, blue: 0.38),
                coolAccent: Color(red: 0.55, green: 0.48, blue: 0.96)
            )
        case .graphite:
            return SaltColorPalette(
                background: Color(red: 0.12, green: 0.12, blue: 0.12),
                surface: Color(red: 0.18, green: 0.18, blue: 0.18),
                elevatedSurface: Color(red: 0.24, green: 0.24, blue: 0.24),
                primaryText: .white,
                secondaryText: Color.white.opacity(0.62),
                accent: Color(red: 0.78, green: 0.82, blue: 0.86),
                warmAccent: Color(red: 0.88, green: 0.55, blue: 0.32),
                coolAccent: Color(red: 0.38, green: 0.64, blue: 0.82)
            )
        }
    }
}

