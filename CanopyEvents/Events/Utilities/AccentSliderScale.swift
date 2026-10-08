/// The editor's Accent slider (shown only while Color is grey), as the
/// web has it: the first 12 steps white (`accentHue` nil), then the hues
/// 0–359, so it lines up with the Color slider.
nonisolated enum AccentSliderScale {
    static let whiteSteps = ThemeSliderScale.greySteps
    static let maximum = whiteSteps + 359

    static func value(for accentHue: Int?) -> Int {
        guard let accentHue, (0...359).contains(accentHue) else { return whiteSteps / 2 }
        return whiteSteps + accentHue
    }

    /// The accent hue at a slider position; nil is white.
    static func accentHue(at value: Int) -> Int? {
        let value = min(max(value, 0), maximum)
        return value < whiteSteps ? nil : min(359, value - whiteSteps)
    }
}
