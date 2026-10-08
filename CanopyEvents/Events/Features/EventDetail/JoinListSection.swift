import SwiftUI

/// "Get invited next time", for a guest who isn't on a list the hosts put
/// on the event (the web's `joinListSection`): "Join Ana's Drag Race? Ana
/// will be able to invite you to events." and "Join Drag Race", which asks
/// first. After joining, it says so in place.
struct JoinListSection: View {
    /// The list to offer; nil once joined.
    let list: JoinableList?
    /// After joining: the membership and how many events it invited you to.
    let joined: ListJoined?
    var isJoining = false
    let onJoin: (JoinableList) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Get invited next time")
                .font(Typography.sectionTitle)
                .accessibilityAddTraits(.isHeader)
            if let joined {
                let first = joined.list.owner.firstName
                Text("You're on \(first)'s \(joined.list.name).")
                if joined.invitedTo > 0 {
                    Text(joined.invitedTo == 1 ? "\(first) invited you to 1 event." : "\(first) invited you to \(joined.invitedTo) events.")
                        .foregroundStyle(Palette.muted)
                }
            } else if let list {
                let first = list.owner.firstName
                Text("Join \(first)'s \(list.name)? \(first) will be able to invite you to events.")
                Button { onJoin(list) } label: {
                    Text("Join \(list.name)")
                        .font(Typography.button)
                        .frame(maxWidth: .infinity)
                }
                .glassButtonStyle()
                .controlSize(.large)
                .disabled(isJoining)
            }
        }
        .glassCard()
    }
}

#Preview {
    let list = JoinableList(code: MockLists.dumplingCrewCode, name: "Dumpling crew", url: "https://events.canopysf.com/l/x", owner: MockPeople.ana)
    ScrollView {
        VStack {
            JoinListSection(list: list, joined: nil) { _ in }
            JoinListSection(list: nil, joined: ListJoined(
                list: ListMembership(id: "x", name: "Dumpling crew", owner: MockPeople.ana, joinedAt: .now), invitedTo: 1)) { _ in }
        }
        .padding()
    }
    .canopyScreen(theme: .hue(225))
}
