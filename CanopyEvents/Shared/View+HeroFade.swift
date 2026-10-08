import SwiftUI

extension View {
    /// The hero picture fading itself out into the page: opaque at the
    /// top, transparent at the foot, over the band the web's fade covers
    /// (clear to 45% of the frame, 30% left at the band's top, gone at
    /// the bottom), so the always-dark mesh shows through and nothing is
    /// drawn over the photo. Pulled down, the picture keeps its own
    /// transparent foot as it stays put, and the content slides over it.
    func heroFade() -> some View {
        mask {
            LinearGradient(
                stops: HeroFade.stops.map { .init(color: .black.opacity(1 - $0.fade), location: $0.location) },
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}

/// The fade's stops, from docs/api.md: where down the frame, and how much
/// of the picture has faded away there.
enum HeroFade {
    static let stops: [(location: Double, fade: Double)] = [
        (0.45, 0), (0.52, 0.06), (0.58, 0.18), (0.63, 0.34), (0.68, 0.52),
        (0.75, 0.70), (0.82, 0.84), (0.90, 0.94), (1, 1),
    ]
}
