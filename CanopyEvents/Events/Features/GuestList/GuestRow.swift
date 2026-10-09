import SwiftUI

/// One person on the guest list, with their plus-ones (flagged when the
/// host has since allowed fewer), and whatever goes on the right.
struct GuestRow<Accessory: View>: View {
    let guest: Guest
    @ViewBuilder var accessory: Accessory

    var body: some View {
        PersonRow(person: guest.person, detail: plusOnes) { accessory }
    }

    private var plusOnes: String? {
        let text: String? = switch guest.guests {
        case 0: nil
        case 1: "+1 guest"
        default: "+\(guest.guests) guests"
        }
        return guest.guestsOverLimit ? text.map { $0 + ", over the limit" } : text
    }
}

extension GuestRow where Accessory == EmptyView {
    init(guest: Guest) {
        self.init(guest: guest) { EmptyView() }
    }
}

#Preview {
    List {
        ForEach(PreviewData.guestList(MockEvents.birthdayId).guests) { GuestRow(guest: $0) }
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
