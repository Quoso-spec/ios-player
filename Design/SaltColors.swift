import SwiftUI

struct SaltColors {
    static let background = Color(hex: "0D0D0D")
    static let surface = Color(hex: "1A1A1A")
    static let surfaceElevated = Color(hex: "242424")
    static let surfaceHighlight = Color(hex: "2E2E2E")

    static let primary = Color(hex: "5B7FFF")
    static let accent = Color(hex: "7C9FFF")

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "A0A0A0")
    static let textTertiary = Color(hex: "666666")

    static let divider = Color(hex: "2A2A2A")

    static let gradientStart = Color(hex: "5B7FFF")
    static let gradientEnd = Color(hex: "9B7FFF")

    static let success = Color(hex: "4CD964")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")

    static let playing = Color(hex: "5B7FFF")
    static let progressBackground = Color(hex: "333333")
    static let progressForeground = Color(hex: "5B7FFF")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toUIColor() -> UIColor {
        UIColor(self)
    }
}
