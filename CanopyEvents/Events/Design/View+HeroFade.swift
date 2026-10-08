import SwiftUI

extension View {
    /// The hero's fade, the web's exactly (docs/api.md): clear to 45% of
    /// the frame, easing to 70% of the theme's base colour at the band's
    /// top (75%) and solid at the foot; then the last 6% melts into the
    /// mesh. Used by the event page's hero and the editor's.
    func heroFade(_ theme: EventTheme) -> some View {
        let base = ThemeColors(theme).base
        return self
            .overlay {
                LinearGradient(
                    stops: HeroFade.stops.map { .init(color: base.color(opacity: $0.opacity), location: $0.location) },
                    startPoint: .top, endPoint: .bottom
                )
            }
            .mask {
                LinearGradient(stops: [.init(color: .black, location: 0.94), .init(color: .clear, location: 1)],
                               startPoint: .top, endPoint: .bottom)
            }
    }
}

/// The fade's stops: (where down the frame, how much of the base colour).
enum HeroFade {
    static let stops: [(location: Double, opacity: Double)] = [
        (0.45, 0), (0.52, 0.06), (0.58, 0.18), (0.63, 0.34), (0.68, 0.52),
        (0.75, 0.70), (0.82, 0.84), (0.90, 0.94), (1, 1),
    ]
}
