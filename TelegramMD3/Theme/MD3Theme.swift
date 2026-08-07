import SwiftUI

// Вспомогательное расширение для создания динамических цветов
extension Color {
    static func dynamic(light: Int, dark: Int) -> Color {
        Color(UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            let r = CGFloat((hex >> 16) & 0xFF) / 255.0
            let g = CGFloat((hex >> 8) & 0xFF) / 255.0
            let b = CGFloat(hex & 0xFF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        })
    }
}

// MD3 Палитра
struct MD3Theme {
    static let primary = Color.dynamic(light: 0x6750A4, dark: 0xD0BCFF)
    static let onPrimary = Color.dynamic(light: 0xFFFFFF, dark: 0x381E72)

    static let primaryContainer = Color.dynamic(light: 0xEADDFF, dark: 0x4F378B)
    static let onPrimaryContainer = Color.dynamic(light: 0x21005D, dark: 0xEADDFF)

    static let secondaryContainer = Color.dynamic(light: 0xE8DEF8, dark: 0x4A4458)
    static let onSecondaryContainer = Color.dynamic(light: 0x1D192B, dark: 0xE8DEF8)

    static let surface = Color.dynamic(light: 0xFEF7FF, dark: 0x141218)
    static let onSurface = Color.dynamic(light: 0x1D1B20, dark: 0xE6E0E9)

    static let surfaceVariant = Color.dynamic(light: 0xE7E0EC, dark: 0x49454F)
    static let onSurfaceVariant = Color.dynamic(light: 0x49454F, dark: 0xCAC4D0)

    static let outline = Color.dynamic(light: 0x79747E, dark: 0x938F99)
}
