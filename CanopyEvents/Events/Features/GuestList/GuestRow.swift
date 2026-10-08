import SwiftUI

/// One person on the guest list, with their plus-ones.
struct GuestRow: View {
    let guest: Guest

    var body: some View {
        PersonRow(person: guest.person, detail: plusOnes)
    }

    private var plusOnes: String? {
        switch guest.guests {
        case 0: nil
        case 1: "+1 guest"
        default: "+\(guest.guests) guests"
        }
    }
}

#Preview {
    List {
        ForEach(PreviewData.guestList(MockEvents.birthdayId).guests) { GuestRow(guest: $0) }
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
