import Foundation
import SwiftUI

public enum SaltThemeVariant: String, CaseIterable, Identifiable, Codable, Sendable {
    case dusk
    case light
    case midnight
    case graphite

    public var id: String { rawValue }
}

public enum PlayerBackgroundStyle: String, Codable, Sendable {
    case fluidGradient
    case blurredArtwork
    case calmMaterial
}

public struct SaltColorPalette {
    public var background: Color
    public var surface: Color
    public var elevatedSurface: Color
    public var primaryText: Color
    public var secondaryText: Color
    public var accent: Color
    public var warmAccent: Color
    public var coolAccent: Color

    public init(
        background: Color,
        surface: Color,
        elevatedSurface: Color,
        primaryText: Color,
        secondaryText: Color,
        accent: Color,
        warmAccent: Color,
        coolAccent: Color
    ) {
        self.background = background
        self.surface = surface
        self.elevatedSurface = elevatedSurface
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.accent = accent
        self.warmAccent = warmAccent
        self.coolAccent = coolAccent
    }
}

public struct SaltTypographyScale: Equatable, Sendable {
    public var titleSize: Double
    public var bodySize: Double
    public var captionSize: Double

    public init(titleSize: Double = 24, bodySize: Double = 16, captionSize: Double = 12) {
        self.titleSize = titleSize
        self.bodySize = bodySize
        self.captionSize = captionSize
    }
}

@MainActor
public protocol ThemeProviding: ObservableObject {
    var variant: SaltThemeVariant { get set }
    var palette: SaltColorPalette { get }
    var typography: SaltTypographyScale { get }
    var playerBackgroundStyle: PlayerBackgroundStyle { get set }
}
