import SwiftUI

/// Hosts pick friends (people they've been to events with) to invite.
/// Each invitee sees the event in their Invites tab.
struct InviteFriendsSheet: View {
    /// Called after invites are sent and the sheet closes.
    let onInvited: () -> Void

    @Environment(\.eventsRepository) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var model: InviteFriendsModel

    init(eventId: Event.ID, onInvited: @escaping () -> Void) {
        self.onInvited = onInvited
        _model = State(initialValue: InviteFriendsModel(eventId: eventId))
    }

    var body: some View {
        NavigationStack {
            List(model.friends) { friend in
                Button {
                    model.toggle(friend)
                } label: {
                    InviteFriendRow(
                        friend: friend,
                        isSelected: model.selected.contains(friend.id),
                        isAlreadyInvited: model.alreadyOnList.contains(friend.id)
                    )
                }
                .buttonStyle(.plain)
            }
            .overlay { emptyState }
            .navigationTitle("Invite friends")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Invite \(model.selected.count)", role: .confirm) { Task { await send() } }
                        .disabled(model.selected.isEmpty || model.isSending)
                }
            }
            .task { await model.load(from: repository) }
            .errorAlert($model.errorMessage)
            .canopyScreen()
        }
    }

    @ViewBuilder private var emptyState: some View {
        if !model.hasLoaded {
            ProgressView()
        } else if model.friends.isEmpty {
            ContentUnavailableView(
                "No friends yet",
                systemImage: "person.2",
                description: Text("People you've been to events with show up here. Share the event's link to invite anyone.")
            )
        }
    }

    private func send() async {
        guard await model.send(using: repository) else { return }
        dismiss()
        onInvited()
    }
}

#Preview {
    InviteFriendsSheet(eventId: MockEvents.birthdayId) {}
        .mockEnvironment()
}

#Preview("No friends yet") {
    InviteFriendsSheet(eventId: MockEvents.birthdayId) {}
        .mockEnvironment(signedInAs: MockPeople.ada)
}
