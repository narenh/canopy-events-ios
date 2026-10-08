/// A page of an event's guest list as you're allowed to see it (the
/// API's `GuestList`). When `guestsVisible` is false, `guests` is empty
/// and only `counts` says anything. In the order people got their status.
nonisolated struct GuestList: Codable, Hashable {
    var guestsVisible: Bool
    var guests: [Guest]
    var counts: RSVPCounts
    /// Pass back for the next page; nil at the end.
    var nextCursor: String?

    func guests(with status: RSVPStatus) -> [Guest] {
        guests.filter { $0.status == status }
    }
}
