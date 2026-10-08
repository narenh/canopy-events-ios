import SwiftUI

/// A list you're on: its owner's face, its name, whose it is, and Leave.
struct ListMembershipRow: View {
    let membership: ListMembership
    let onLeave: () -> Void

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Avatar(person: membership.owner)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(membership.name)
                Text("\(membership.owner.fullName)'s list")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 0)
            Button("Leave", action: onLeave)
                .buttonStyle(.borderless)
                .accessibilityLabel("Leave \(membership.name)")
        }
    }
}

#Preview {
    List {
        ListMembershipRow(membership: ListMembership(id: "x", name: "Supper club", owner: MockPeople.lena, joinedAt: .now)) {}
    }
    .canopyScreen()
}
