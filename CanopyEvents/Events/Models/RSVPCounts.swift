/// How many people are in each status (the API's `Counts`). Always
/// visible to everyone, even when the guest list's names are hidden,
/// except `invited`, which only hosts get (nil for anyone else). Hosts
/// and removed people aren't counted.
///
/// The top-level numbers are **people**. `guests` is the plus-ones those
/// people bring, and `total` is the two together: "6 going" on a screen
/// is `total.going`; "4 people (+2)" is `going` and `guests.going`.
nonisolated struct RSVPCounts: Codable, Hashable {
    var going = 0
    var maybe = 0
    var notGoing = 0
    var invited: Int? = 0
    var waitlisted = 0
    var guests = GuestCounts()
    var total = GuestCounts()

    /// People with that status (not counting their plus-ones).
    func count(for status: RSVPStatus) -> Int {
        switch status {
        case .invited: invited ?? 0
        case .going: going
        case .maybe: maybe
        case .notGoing: notGoing
        case .waitlisted: waitlisted
        case .removed: 0
        }
    }
}
