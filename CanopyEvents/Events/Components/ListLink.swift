import SwiftUI

/// A full-width glass link at the top of a list ("Past events",
/// "Declined"), the same glass as the cards under it.
struct ListLink: View {
    let title: String
    let systemImage: String
    let route: Route

    var body: some View {
        NavigationLink(value: route) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Palette.muted)
            }
            .font(.body.weight(.semibold))
            .contentShape(.rect)
            .padding(.vertical, -Spacing.xSmall)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}
