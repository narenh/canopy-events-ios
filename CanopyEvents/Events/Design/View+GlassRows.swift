import SwiftUI

extension View {
    /// Glass behind a `List` or `Form` row instead of the system's solid
    /// grey: apply to each `Section` (or row). With the list's own
    /// background hidden (`canopyScreen()` does it; sheets use
    /// `glassList()`), a section reads as one glass card over the mesh or
    /// the sheet, like the event page's cards.
    func glassRowBackground() -> some View {
        listRowBackground(GlassRowBackground())
    }

    /// For a `List` or `Form` in a sheet: the sheet's own background shows
    /// through (rows take `glassRowBackground()`).
    func glassList() -> some View {
        scrollContentBackground(.hidden)
    }
}

/// The glass behind one list row: the same Liquid Glass as `glassCard()`,
/// square, since the list rounds each section's corners itself.
private struct GlassRowBackground: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .glassSurface(cornerRadius: 0)
    }
}
