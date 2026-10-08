import Foundation

extension MockRules {
    /// The guest list as `me` may see it: names only when allowed. Non-hosts
    /// see answers only; hosts also see who's invited with no answer, and
    /// removed people only when they ask for `status: .removed`.
    static func guestList(_ record: MockEventRecord, for me: Person, status: RSVPStatus? = nil) -> GuestList {
        let viewer = viewer(record, for: me)
        let counts = counts(record)
        guard viewer.canSeeGuestList else {
            return GuestList(guestsVisible: false, guests: [], counts: counts, nextCursor: nil)
        }
        let visible = record.guests.filter { guest in
            if let status { return guest.status == status }
            return guest.status != .removed && (viewer.isHost || guest.status.isAnswer)
        }
        return GuestList(
            guestsVisible: true,
            guests: visible.map { resolved($0, in: record) },
            counts: counts,
            nextCursor: nil
        )
    }
}
