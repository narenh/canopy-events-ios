import SwiftUI

/// Someone in a picker: their face, name and how you know them (a friend
/// link is an icon, read as "Friend link"), and a tick. Already there,
/// they're greyed and can't be ticked: on the event with their status
/// badge (the fixed status colors), on the list with "On list".
struct PickerPersonRow: View {
    let candidate: PeoplePicker.Candidate
    let status: PeoplePicker.Status?
    let isPicked: Bool
    let onToggle: () -> Void

    private var person: Person { candidate.person }

    var body: some View {
        Button(action: onToggle) {
            PersonRow(person: person, detail: candidate.detail.isEmpty ? nil : candidate.detail,
                      isFriendLink: candidate.isFriendLink) {
                switch status {
                case .hosting: StatusBadge(kind: .hosting)
                case .rsvp(let rsvp): StatusBadge(kind: .status(rsvp))
                case .onList: PlainTag(title: "On list")
                case nil:
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

    private func words(_ status: PeoplePicker.Status) -> String {
        switch status {
        case .hosting: "Hosting"
        case .rsvp(.waitlisted): "On the waitlist"
        case .rsvp(let rsvp): rsvp.title
        case .onList: "On list"
        }
    }
}

#Preview {
    List {
        PickerPersonRow(candidate: .init(person: MockPeople.ana, detail: "Invitation, 3 events together"), status: nil, isPicked: true) {}
        PickerPersonRow(candidate: .init(person: MockPeople.ines, detail: "2 events together", isFriendLink: true), status: nil, isPicked: false) {}
        PickerPersonRow(candidate: .init(person: MockPeople.theo, detail: "On Drag Race"), status: nil, isPicked: false) {}
        PickerPersonRow(candidate: .init(person: MockPeople.ben, detail: "4 events together"), status: .rsvp(.going), isPicked: false) {}
        PickerPersonRow(candidate: .init(person: MockPeople.chloe, detail: ""), status: .hosting, isPicked: false) {}
        PickerPersonRow(candidate: .init(person: MockPeople.diego, detail: ""), status: .onList, isPicked: false) {}
    }
    .canopyScreen()
}
