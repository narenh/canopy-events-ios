/// The editor's Color slider, as the web has it: 0 to 371, the first 12
/// steps grey (no color, about 3% of the track: it's one value, not a
/// range), then the hues 0–359. An untouched new event sits on Canopy
/// green's hue.
nonisolated enum ThemeSliderScale {
    static let greySteps = 12
    static let maximum = greySteps + 359

    static func value(for theme: EventTheme) -> Int {
        switch theme {
        case .grayscale: greySteps / 2
        case .hue(let hue): greySteps + hue
        case .canopyGreen: greySteps + EventTheme.canopyHue
        }
    }

    /// The theme at a slider position. Green's own hue is still a hue
    /// here; the editor keeps an untouched slider's nil itself.
    static func theme(at value: Int) -> EventTheme {
        let value = min(max(value, 0), maximum)
        return value < greySteps ? .grayscale : .hue(min(359, value - greySteps))
    }
}
