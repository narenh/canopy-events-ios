import SwiftUI

extension View {
    /// Puts the Canopy mesh behind a screen and lets it show through
    /// lists and forms. Apply once, to a screen's outermost view.
    func canopyScreen() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background { CanopyBackground() }
    }
}
