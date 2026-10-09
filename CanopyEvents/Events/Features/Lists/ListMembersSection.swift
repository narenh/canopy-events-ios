import SwiftUI

/// "People · 9" in a list's sheet: Add people, then everyone on it newest
/// first (or whoever's name matches the search), each with "Joined Oct 8"
/// or "Added Oct 8"; swipe to take someone off (the sheet asks first).
struct ListMembersSection: View {
    let list: OwnedList
    /// The ones to show: everyone, or the matches.
    let members: [ListMember]
    let isSearching: Bool
    let onAdd: () -> Void
    let onRemove: (ListMember) -> Void

    var body: some View {
        Section {
            if !isSearching {
                Button(action: onAdd) {
                    Label("Add people", systemImage: "person.badge.plus")
                        .font(Typography.button)
                }
            }
            if members.isEmpty {
                Text(isSearching ? "No one on it by that name."
                                 : "Add people, or share the link or QR code: whoever joins shows up here.")
                    .foregroundStyle(Palette.muted)
            }
            ForEach(members) { member in
                PersonRow(person: member.person, detail: JoinedDate.string(for: member.joinedAt, source: member.source))
                    .accessibilityElement(children: .combine)
                    .swipeActions {
                        Button("Remove", systemImage: "person.badge.minus", role: .destructive) { onRemove(member) }
                    }
                    .accessibilityAction(named: "Remove") { onRemove(member) }
            }
        } header: {
            Text(list.memberCount > 0 ? "People · \(list.memberCount)" : "People")
        }
        .glassRowBackground()
    }
}

#Preview {
    let list = PreviewData.ownedList(MockLists.climbingId)
    List {
        ListMembersSection(list: list, members: MockLists.all[1].members.reversed(), isSearching: false,
                           onAdd: {}, onRemove: { _ in })
    }
    .canopyScreen()
}
