import SwiftUI

/// A list in the host's "Lists…": a list icon, its name, a line under
/// it, and a button.
struct EventListRow<Accessory: View>: View {
    let name: String
    let detail: String
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Image(systemName: "list.bullet")
                .foregroundStyle(Palette.muted)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(name)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 0)
            accessory
        }
    }
}

#Preview {
    List {
        EventListRow(name: "Drag Race", detail: "Your list · 20 people") { Button("Take off") {} }
        EventListRow(name: "Climbing", detail: "5 people") { Button("Add") {} }
    }
    .canopyScreen()
}
