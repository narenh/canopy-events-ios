import SwiftUI

/// An event's background colours: the dark mesh's base, its five glows
/// and the cards' glass tint, worked out from its `EventTheme` exactly as
/// docs/api.md ("Event colours") and the web's `themeColors` do. Each
/// colour keeps its OKLCH lightness and chroma and takes the theme's hue
/// plus its own offset; grey keeps the lightness with no chroma; Canopy
/// green is the web's hex values exactly.
nonisolated struct ThemeColors: Hashable, Sendable {
    /// The page behind everything (and the colour the cover fades into).
    var base: RGB
    /// Top left, top right, lower right (the brightest), lower left, middle.
    var glow1: RGB
    var glow2: RGB
    var glow3: RGB
    var glow4: RGB
    var glow5: RGB
    /// The glass tint, drawn at 30% opacity.
    var card: RGB
    /// The accent (Canopy green's #2ec44f turned to the theme), the text
    /// and icons on it (#03190a), and links and accent text (#b6f5c3):
    /// the web's `--accent`, `--on-accent` and `--accent-text`.
    var accent: RGB
    var onAccent: RGB
    var accentText: RGB

    /// Canopy green, the default: today's hex values exactly.
    static let canopyGreen = ThemeColors(
        base: RGB(hex: "#03120c"), glow1: RGB(hex: "#0f4a33"), glow2: RGB(hex: "#0a3b2e"),
        glow3: RGB(hex: "#145c3e"), glow4: RGB(hex: "#072b1f"), glow5: RGB(hex: "#0c3a28"),
        card: RGB(hex: "#03200b"),
        accent: RGB(hex: "#2ec44f"), onAccent: RGB(hex: "#03190a"), accentText: RGB(hex: "#b6f5c3")
    )

    /// (L, C, hue offset) for each colour, from docs/api.md's table.
    private static let mesh: [(Double, Double, Double)] = [
        (0.1652, 0.0266, 6.4), (0.3655, 0.0715, 1.4), (0.3166, 0.0559, 9.8), (0.4233, 0.0856, -0.4),
        (0.2597, 0.0466, 5.8), (0.3122, 0.0590, 1.9), (0.2150, 0.0537, -11.2),
    ]

    init(base: RGB, glow1: RGB, glow2: RGB, glow3: RGB, glow4: RGB, glow5: RGB, card: RGB,
         accent: RGB, onAccent: RGB, accentText: RGB) {
        self.base = base
        self.glow1 = glow1
        self.glow2 = glow2
        self.glow3 = glow3
        self.glow4 = glow4
        self.glow5 = glow5
        self.card = card
        self.accent = accent
        self.onAccent = onAccent
        self.accentText = accentText
    }

    init(_ theme: EventTheme) {
        guard theme != .canopyGreen else {
            self = .canopyGreen
            return
        }
        let c = Self.mesh.map { L, C, offset in Self.themed(L: L, C: C, hue: Double(theme.hueValue) + offset, theme) }
        let green = Self.canopyGreen
        self.init(base: c[0], glow1: c[1], glow2: c[2], glow3: c[3], glow4: c[4], glow5: c[5], card: c[6],
                  accent: Self.turn(green.accent, to: theme), onAccent: Self.turn(green.onAccent, to: theme),
                  accentText: Self.turn(green.accentText, to: theme))
    }

    /// Any Canopy-green colour turned to a theme the same way: its offset
    /// from green's hue and its lightness kept (the web's `turnHex`).
    static func turn(_ green: RGB, to theme: EventTheme) -> RGB {
        guard theme != .canopyGreen else { return green }
        let (L, C, h) = OKLCH.components(of: green)
        return themed(L: L, C: C, hue: Double(theme.hueValue) + h - Double(EventTheme.canopyHue), theme)
    }

    private static func themed(L: Double, C: Double, hue: Double, _ theme: EventTheme) -> RGB {
        theme == .grayscale
            ? OKLCH.rgb(L: L, C: 0, h: 0)
            : OKLCH.rgb(L: L, C: C, h: (hue + 360).truncatingRemainder(dividingBy: 360))
    }
}

nonisolated private extension EventTheme {
    /// The hue the maths turns to (grey's is ignored, since it has no chroma).
    var hueValue: Int {
        switch self {
        case .hue(let hue): hue
        case .canopyGreen: EventTheme.canopyHue
        case .grayscale: 0
        }
    }
}
