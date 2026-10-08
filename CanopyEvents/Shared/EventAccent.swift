import SwiftUI

/// The accent on an event's own screens (its page, its editor, its
/// notification card): Canopy green's accent colours turned to the
/// event's colour, as the web's `themeStyle` does. Everywhere else stays
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

    init(_ theme: EventTheme) {
        let colors = ThemeColors(theme)
        accent = colors.accent.color
        onAccent = colors.onAccent.color
        text = colors.accentText.color
    }

    static let canopyGreen = EventAccent(.canopyGreen)
}

extension EnvironmentValues {
    /// The accent for the event on screen; Canopy green elsewhere.
    @Entry var eventAccent = EventAccent.canopyGreen
}

extension View {
    /// Turns the accent (and the tint) to an event's colour for this view
    /// and everything in it.
    func eventAccent(_ theme: EventTheme) -> some View {
        let accent = EventAccent(theme)
        return self
            .tint(accent.accent)
            .environment(\.eventAccent, accent)
    }
}
