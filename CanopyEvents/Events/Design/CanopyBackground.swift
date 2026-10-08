import SwiftUI

/// The dark mesh behind every screen: soft glows on near-black, the
/// native version of the web's `.mesh-bg`. Canopy green everywhere except
/// an event's own page and editor, which pass the event's theme.
///
/// The web draws five radial glows; a 3×3 mesh puts each near its spot:
/// glow 1 top left, glow 2 top right, glow 5 in the middle, glow 4 lower
/// left and glow 3 (the brightest) low on the right.
struct CanopyBackground: View {
    var theme: EventTheme = .canopyGreen

    var body: some View {
        let c = ThemeColors(theme)
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.45], [1, 0.55],
                [0, 1], [0.72, 1], [1, 1],
            ],
            colors: [
                c.glow1.color, c.base.color, c.glow2.color,
                c.base.color, c.glow5.color, c.base.color,
                c.glow4.color, c.glow3.color, c.base.color,
            ]
        )
        .ignoresSafeArea()
        .animation(.easeOut(duration: 0.25), value: theme)
    }
}

#Preview("Green, a hue, grey") {
    VStack(spacing: 0) {
        CanopyBackground()
        CanopyBackground(theme: .hue(300))
        CanopyBackground(theme: .grayscale)
    }
}
