import SwiftUI

/// Liquid Glass in one place. iOS and macOS 26 have Liquid Glass; visionOS
/// doesn't (it has its own glass material), so each helper picks the
/// right look per platform. Use these instead of `.glassEffect` and
/// `.buttonStyle(.glass)` directly, so no screen needs `#if os(...)`.
extension View {
    /// A Liquid Glass surface behind this view, in a rounded rectangle.
    func glassSurface(cornerRadius: CGFloat, tint: Color? = nil) -> some View {
        #if os(visionOS)
        glassBackgroundEffect(in: .rect(cornerRadius: cornerRadius))
        #else
        glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
        #endif
    }

    /// The main action on a screen: tinted glass in the accent color.
    func glassProminentButtonStyle() -> some View {
        #if os(visionOS)
        buttonStyle(.borderedProminent)
        #else
        buttonStyle(.glassProminent)
        #endif
    }

    /// A secondary action: clear glass, with white words (an explicit
    /// `.tint()`, like an event's accent, would otherwise color them; a
    /// `foregroundStyle` on the label still wins).
    func glassButtonStyle() -> some View {
        #if os(visionOS)
        buttonStyle(.bordered).foregroundStyle(.white)
        #else
        buttonStyle(.glass).foregroundStyle(.white)
        #endif
    }
}
