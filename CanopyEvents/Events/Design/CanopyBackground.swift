import SwiftUI

/// The dark green mesh behind every screen: soft glows on near-black,
/// the native version of the web's `.mesh-bg`.
struct CanopyBackground: View {
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.55, 0.45], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1],
            ],
            colors: [
                Palette.glow, Palette.base, Palette.glowSoft,
                Palette.base, Palette.glowDeep, Palette.base,
                Palette.glowDeep, Palette.glowBright, Palette.base,
            ]
        )
        .ignoresSafeArea()
    }
}

#Preview {
    CanopyBackground()
}
