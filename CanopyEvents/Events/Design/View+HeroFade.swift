import SwiftUI

extension View {
    /// Melts the bottom of a hero layer into the mesh, so no edge shows
    /// against the glows: the fade's last 6%, as the web's mask does, or
    /// (`from: 0.75`) the picture across its whole band, which at rest sits
    /// under the fade anyway and, pulled down, leaves no line where the
    /// picture ends.
    func heroMelt(from start: Double = 0.94) -> some View {
        mask {
            LinearGradient(stops: [.init(color: .black, location: start), .init(color: .clear, location: 1)],
                           startPoint: .top, endPoint: .bottom)
        }
    }
}

/// The hero's fade, the web's exactly (docs/api.md): clear to 45% of the
/// frame, easing to 70% of the theme's base colour at the band's top
/// (75%) and solid at the foot, then melting into the mesh. It belongs to
/// the page's content, not the picture: pulled down, it travels with the
/// title over the picture, which stays put.
struct HeroFade: View {
    let theme: EventTheme

    /// (where down the frame, how much of the base colour).
    static let stops: [(location: Double, opacity: Double)] = [
        (0.45, 0), (0.52, 0.06), (0.58, 0.18), (0.63, 0.34), (0.68, 0.52),
        (0.75, 0.70), (0.82, 0.84), (0.90, 0.94), (1, 1),
    ]

    var body: some View {
        let base = ThemeColors(theme).base
        LinearGradient(
            stops: Self.stops.map { .init(color: base.color(opacity: $0.opacity), location: $0.location) },
            startPoint: .top, endPoint: .bottom
        )
        .heroMelt()
        .allowsHitTesting(false)
    }
}
