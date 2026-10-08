import SwiftUI

extension View {
    /// Wraps content in a padded Liquid Glass card, the building block of
    /// the event page. Use for a section that sits on the mesh background.
    func glassCard() -> some View {
        self
            .padding(Spacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: Radius.large))
    }
}
