import SwiftUI

/// A friend in the invite picker: events in common, and a checkmark.
struct InviteFriendRow: View {
    let friend: Friend
    let isSelected: Bool
    let isAlreadyInvited: Bool

    var body: some View {
        PersonRow(person: friend.person, detail: detail) {
            Image(systemName: isSelected || isAlreadyInvited ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isAlreadyInvited ? Color.secondary : Color.accentColor)
        }
        .opacity(isAlreadyInvited ? 0.6 : 1)
    }

    private var detail: String {
        if isAlreadyInvited { return "Already on the list" }
        let together = friend.eventsInCommon == 1 ? "1 event together" : "\(friend.eventsInCommon) events together"
        return "\(together) · last \(RelativeTime.string(for: friend.lastTogetherAt))"
    }
}

#Preview {
    List {
        InviteFriendRow(friend: PreviewData.friends[0], isSelected: false, isAlreadyInvited: false)
        InviteFriendRow(friend: PreviewData.friends[1], isSelected: true, isAlreadyInvited: false)
        InviteFriendRow(friend: PreviewData.friends[2], isSelected: false, isAlreadyInvited: true)
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
