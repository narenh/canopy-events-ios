/// You and one event: whether you host it, your RSVP, and what you may
/// do (the API's `Viewer`). Nil on an event when signed out.
nonisolated struct Viewer: Codable, Hashable {
    /// Your part in hosting it, or nil if you're a guest.
    var role: HostRole?
    var rsvp: RSVP?
    var canEdit: Bool
    /// Whether the guest list's names are shown to you. The wall follows
    /// the same rule.
    var canSeeGuestList: Bool
    /// Whether you may post on the wall: hosts, and answers of going,
    /// maybe or waitlisted.
    var canPost: Bool
    /// You muted this event: its chatter doesn't reach your inbox. Always
    /// false for a host.
    var muted: Bool

    var isHost: Bool { role != nil }
    var isCreator: Bool { role == .creator }
}
