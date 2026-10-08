/// You and one event: whether you host it, your RSVP, and what you may
/// do. Nil on an event when signed out.
nonisolated struct Viewer: Codable, Hashable {
    /// Your part in hosting it, or nil if you're a guest.
    var role: HostRole?
    var rsvp: RSVP?
    var canEdit: Bool
    /// Whether the guest list's names are shown to you.
    var canSeeGuestList: Bool

    var isHost: Bool { role != nil }
}
