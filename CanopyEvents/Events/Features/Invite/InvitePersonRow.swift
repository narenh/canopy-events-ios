import SwiftUI

/// Someone in the invite sheet: their face, name and how you know them
/// (a friend link is an icon, read as "Friend link"), and a tick. Already on the event, they're greyed with their status
/// badge (the fixed status colors) and can't be ticked.
struct InvitePersonRow: View {
    let candidate: InvitePicker.Candidate
    let status: InvitePicker.Status?
    let isPicked: Bool
    let onToggle: () -> Void

    private var person: Person { candidate.person }

    var body: some View {
        Button(action: onToggle) {
            PersonRow(person: person, detail: candidate.detail.isEmpty ? nil : candidate.detail,
                      isFriendLink: candidate.isFriendLink) {
                if let status {
                    StatusBadge(kind: badge(status))
                } else {
                    Image(systemName: isPicked ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isPicked ? Color.accentColor : Palette.muted)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(status != nil)
        .opacity(status == nil ? 1 : 0.55)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([person.fullName, candidate.isFriendLink ? "Friend link" : "", candidate.detail]
            .filter { !$0.isEmpty }.joined(separator: ", "))
        .accessibilityValue(status.map(words) ?? (isPicked ? "Picked" : ""))
        .accessibilityAddTraits(status == nil ? [.isButton] : [])
        .accessibilityAddTraits(isPicked ? .isSelected : [])
        .accessibilityAction { if status == nil { onToggle() } }
    }

    private func badge(_ status: InvitePicker.Status) -> StatusBadge.Kind {
        switch status {
        case .hosting: .hosting
        case .rsvp(let rsvp): .status(rsvp)
        }
    }

    private func words(_ status: InvitePicker.Status) -> String {
        switch status {
        case .hosting: "Hosting"
        case .rsvp(.waitlisted): "On the waitlist"
        case .rsvp(let rsvp): rsvp.title
        }
    }
}

#Preview {
    List {
        InvitePersonRow(candidate: .init(person: MockPeople.ana, detail: "Invitation, 3 events together"), status: nil, isPicked: true) {}
        InvitePersonRow(candidate: .init(person: MockPeople.ines, detail: "2 events together", isFriendLink: true), status: nil, isPicked: false) {}
        InvitePersonRow(candidate: .init(person: MockPeople.theo, detail: "On Drag Race"), status: nil, isPicked: false) {}
        InvitePersonRow(candidate: .init(person: MockPeople.ben, detail: "4 events together"), status: .rsvp(.going), isPicked: false) {}
        InvitePersonRow(candidate: .init(person: MockPeople.chloe, detail: ""), status: .hosting, isPicked: false) {}
    }
    .canopyScreen()
}
