import SwiftUI

/// Someone in the guests sheet: their plus-ones, their status while
/// searching (every tab at once), and for hosts, Remove (a swipe; the
/// sheet asks first) or, for the removed, Undo. Guests get no actions.
struct GuestSheetRow: View {
    let guest: Guest
    let showsStatus: Bool
    let isHost: Bool
    let onRemove: (Guest) -> Void
    let onUndo: (Guest) -> Void

    var body: some View {
        GuestRow(guest: guest) {
            if showsStatus { StatusBadge(kind: .status(guest.status)) }
            if isHost, guest.status == .removed {
                Button("Undo") { onUndo(guest) }
                    .buttonStyle(.borderless)
                    .font(.subheadline.weight(.semibold))
                    .accessibilityLabel("Undo removing \(guest.person.fullName)")
            }
        }
        .swipeActions {
            if isHost, guest.status != .removed {
                Button("Remove", systemImage: "person.badge.minus", role: .destructive) { onRemove(guest) }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityActions {
            if isHost, guest.status != .removed {
                Button("Remove") { onRemove(guest) }
            }
        }
    }
}

#Preview {
    let guests = PreviewData.guestList(MockEvents.gameNightId).guests
    List {
        ForEach(guests.prefix(3)) { GuestSheetRow(guest: $0, showsStatus: false, isHost: true, onRemove: { _ in }, onUndo: { _ in }) }
        ForEach(guests.suffix(2)) { GuestSheetRow(guest: $0, showsStatus: true, isHost: false, onRemove: { _ in }, onUndo: { _ in }) }
    }
    .canopyScreen()
}
