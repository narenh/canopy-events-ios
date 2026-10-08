import SwiftUI

/// The accent on an event's own screens (its page, its editor, its
/// notification card), from its `AccentColors`. Everywhere else stays
/// Canopy green. Read it with `@Environment(\.eventAccent)`; set it with
/// `.eventAccent(_:)`, which also sets the tint (prominent buttons, the
/// selected answer, toggles).
struct EventAccent: Hashable {
    /// Buttons, the "how soon" pill, icons.
    var accent: Color
    /// Text and icons on the accent.
    var onAccent: Color
    /// Links and accent text.
    var text: Color
    /// White on a grey event: draw links bold and underlined, since body
    /// text is white too.
    var isWhite: Bool

    init(_ colors: AccentColors) {
        accent = colors.accent.color
        onAccent = colors.onAccent.color
        text = colors.text.color
        isWhite = colors.isWhite
    }

    static let canopyGreen = EventAccent(.canopyGreen)
}

extension EnvironmentValues {
    /// The accent for the event on screen; Canopy green elsewhere.
    @Entry var eventAccent = EventAccent.canopyGreen
}

extension View {
    /// Turns the accent (and the tint) to an event's for this view and
    /// everything in it.
    func eventAccent(_ colors: AccentColors) -> some View {
        let accent = EventAccent(colors)
        return self
            .tint(accent.accent)
            .environment(\.eventAccent, accent)
    }

    /// The main action, in the accent, with the text and icons the
    /// accent takes (dark on a bright accent; the grey base on white), as
    /// the web's main button. Green screens get Canopy green's.
    func accentProminentButtonStyle() -> some View {
        modifier(AccentProminent())
    }

    /// A link's look in the event's accent: its color, and, when the
    /// accent is white, bold with an underline.
    func accentLink(_ accent: EventAccent) -> some View {
        self
            .foregroundStyle(accent.text)
            .fontWeight(accent.isWhite ? .bold : nil)
            .underline(accent.isWhite)
    }
}

private struct AccentProminent: ViewModifier {
    @Environment(\.eventAccent) private var accent

    func body(content: Content) -> some View {
        content
            .glassProminentButtonStyle()
            .tint(accent.accent)
            .foregroundStyle(accent.onAccent)
    }
}
