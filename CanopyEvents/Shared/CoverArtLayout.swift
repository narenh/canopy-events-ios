/// The generated picture for an event with no cover: soft glows in
/// Canopy greens on a dark base, placed and coloured by the event's id
/// (so an event always looks the same), turned to its theme. A port of
/// the web's `coverArt`, number for number.
nonisolated struct CoverArtLayout: Hashable {
    /// The dark end of the wash, the wash's colour, and the two glows.
    var dark: RGB
    var wash: RGB
    var glow1: RGB
    var glow2: RGB
    /// The glows' centres, 0–1 across and down.
    var glow1X: Double
    var glow1Y: Double
    var glow2X: Double
    var glow2Y: Double
    /// The wash's direction, in CSS degrees (0 is up, 90 is right).
    var angle: Double

    private static let greens = [
        ["#145c3e", "#2ec44f", "#0f5a5a"], ["#0f4a33", "#7fbf3f", "#145c3e"], ["#0a3b2e", "#3fa86b", "#b6f5c3"],
        ["#1f7a4d", "#0c3a28", "#9be0a8"], ["#0f5a5a", "#2ec44f", "#0a3b2e"], ["#145c3e", "#d7e86b", "#0f4a33"],
    ]

    init(eventId: String, theme: EventTheme) {
        let seed = Self.seed(of: eventId)
        func part(_ n: UInt32, _ shift: UInt32) -> UInt32 { (seed >> shift) % n }
        let colors = Self.greens[Int(part(UInt32(Self.greens.count), 0))].map {
            ThemeColors.turn(RGB(hex: $0), to: theme)
        }
        dark = ThemeColors.turn(RGB(hex: "#03120c"), to: theme)
        wash = colors[0]
        glow1 = colors[1]
        glow2 = colors[2]
        glow1X = Double(8 + part(45, 3)) / 100
        glow1Y = Double(10 + part(40, 9)) / 100
        glow2X = Double(50 + part(45, 14)) / 100
        glow2Y = Double(35 + part(50, 20)) / 100
        angle = Double(90 + part(180, 25))
    }

    /// FNV-1a over the id's characters, as the web's `seedOf`.
    static func seed(of text: String) -> UInt32 {
        var hash: UInt32 = 2_166_136_261
        for unit in text.utf16 {
            hash = (hash ^ UInt32(unit)) &* 16_777_619
        }
        return hash
    }
}
