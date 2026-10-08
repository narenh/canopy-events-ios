import SwiftUI

/// An sRGB color as three bytes, the way the web writes its theme
/// colors (`#03120c`), so the app's colors can be checked against the
/// web's to the byte.
nonisolated struct RGB: Hashable, Sendable {
    var red: Int
    var green: Int
    var blue: Int

    init(_ red: Int, _ green: Int, _ blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// From "#rrggbb".
    init(hex: String) {
        let value = Int(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: 16) ?? 0
        self.init((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
    }

    var color: Color {
        Color(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }

    func color(opacity: Double) -> Color {
        color.opacity(opacity)
    }
}
