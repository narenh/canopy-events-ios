/// An event's color as one value: Canopy's own green (`themeHue` null),
/// a hue (`themeHue`, 0–359), or no color at all (`themeGrayscale`
/// true, which wins over any hue). The web calls this the "theme key".
nonisolated enum EventTheme: Hashable, Sendable {
    case canopyGreen
    case hue(Int)
    case grayscale

    /// Canopy green's own hue: `themeHue` 161 looks the same as null.
    static let canopyHue = 161

    init(hue: Int?, grayscale: Bool) {
        if grayscale {
            self = .grayscale
        } else if let hue, (0...359).contains(hue) {
            self = .hue(hue)
        } else {
            self = .canopyGreen
        }
    }

    /// The API's two fields for this theme. Grey keeps `keepingHue`, as
    /// the API does, so turning grey off goes back to it.
    func apiFields(keepingHue: Int? = nil) -> (themeHue: Int?, themeGrayscale: Bool) {
        switch self {
        case .canopyGreen: (nil, false)
        case .hue(let hue): (hue, false)
        case .grayscale: (keepingHue, true)
        }
    }
}
