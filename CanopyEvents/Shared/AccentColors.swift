import Foundation

/// An event's accent (the main buttons, the "how soon" pill, icons,
/// links), as the web's `themeStyle` / `accentTrio` / `accentColors` work
/// it out (docs/api.md, "Event colors"), byte for byte:
///
/// - Canopy green (no hue): `#2ec44f`, `#03190a` on it, links `#b6f5c3`.
/// - A hue H: the accent at H itself, chroma 0.21 (fitted to sRGB), at the
///   lightness where H is most vivid, held between the lightness that
///   keeps the dark text on it at 5:1 and 0.80; the text on it and the
///   links are `#03190a`'s and `#b6f5c3`'s lightness and chroma at H.
/// - A grey event: `accentHue`'s trio, or, with none, white: `#ffffff`,
///   the grey base on it, and white links (bold, thicker underline).
nonisolated struct AccentColors: Hashable, Sendable {
    var accent: RGB
    /// Text and icons on the accent.
    var onAccent: RGB
    /// Links and accent text.
    var text: RGB
    /// White on grey: links are white like the body text, so they're set
    /// apart by weight and a thicker underline.
    var isWhite: Bool

    static let canopyGreen = AccentColors(
        accent: RGB(hex: "#2ec44f"), onAccent: RGB(hex: "#03190a"), text: RGB(hex: "#b6f5c3"), isWhite: false
    )

    init(accent: RGB, onAccent: RGB, text: RGB, isWhite: Bool) {
        self.accent = accent
        self.onAccent = onAccent
        self.text = text
        self.isWhite = isWhite
    }

    init(theme: EventTheme, accentHue: Int?) {
        switch theme {
        case .canopyGreen:
            self = .canopyGreen
        case .hue(let hue):
            self = Self.trio(hue)
        case .grayscale:
            if let accentHue, (0...359).contains(accentHue) {
                self = Self.trio(accentHue)
            } else {
                self.init(accent: RGB(hex: "#ffffff"), onAccent: ThemeColors(.grayscale).base,
                          text: RGB(hex: "#ffffff"), isWhite: true)
            }
        }
    }

    // MARK: The web's accentTrio, line for line

    private static let maxChroma = 0.21

    static func trio(_ hue: Int) -> AccentColors {
        let h = Double(hue)
        let onGreen = OKLCH.components(of: RGB(hex: "#03190a"))
        let linkGreen = OKLCH.components(of: RGB(hex: "#b6f5c3"))
        let on = OKLCH.rgb(L: onGreen.L, C: onGreen.C, h: h)
        var cusp = 0.6
        var best = 0.0
        var L = 0.5
        while L <= 0.9 {
            let c = maxChromaFitting(L: L, h: h)
            if c > best {
                best = c
                cusp = L
            }
            L += 0.01
        }
        var low = 0.9
        L = 0.55
        while L <= 0.9 {
            if contrast(OKLCH.rgb(L: L, C: maxChroma, h: h), on) >= 5 {
                low = L
                break
            }
            L += 0.005
        }
        let lightness = min(0.8, max(cusp, low))
        return AccentColors(accent: OKLCH.rgb(L: lightness, C: maxChroma, h: h), onAccent: on,
                            text: OKLCH.rgb(L: linkGreen.L, C: linkGreen.C, h: h), isWhite: false)
    }

    private static func maxChromaFitting(L: Double, h: Double) -> Double {
        var low = 0.0
        var high = 0.4
        for _ in 0..<22 {
            let mid = (low + high) / 2
            let (r, g, b) = OKLCH.linearSRGB(L: L, C: mid, h: h)
            if [r, g, b].allSatisfy({ $0 >= -0.0001 && $0 <= 1.0001 }) { low = mid } else { high = mid }
        }
        return low
    }

    private static func luminance(_ c: RGB) -> Double {
        0.2126 * OKLCH.linear(c.red) + 0.7152 * OKLCH.linear(c.green) + 0.0722 * OKLCH.linear(c.blue)
    }

    /// The WCAG contrast ratio of two colors.
    static func contrast(_ a: RGB, _ b: RGB) -> Double {
        let x = luminance(a)
        let y = luminance(b)
        return (max(x, y) + 0.05) / (min(x, y) + 0.05)
    }
}
