/// An event's guest list as you're allowed to see it. When
/// `guestsVisible` is false, `guests` is empty and only `counts` says
/// anything. (The API pages this with `nextCursor`; the app doesn't page yet.)
nonisolated struct GuestList: Codable, Hashable {
    var guestsVisible: Bool
    var guests: [Guest]
    var counts: RSVPCounts

    func guests(with status: RSVPStatus) -> [Guest] {
        guests.filter { $0.status == status }
    }
}
