import SwiftUI

extension View {
    /// Puts the Canopy mesh behind a screen and lets it show through
    /// lists and forms. Apply once, to a screen's outermost view. An
    /// event's page and editor pass its theme; everything else is green.
    func canopyScreen(theme: EventTheme = .canopyGreen) -> some View {
        self
            .scrollContentBackground(.hidden)
            .background { CanopyBackground(theme: theme) }
    }
}
