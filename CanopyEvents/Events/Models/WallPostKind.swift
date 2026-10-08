/// What kind of entry is on an event's activity wall.
nonisolated enum WallPostKind: String, Codable, Hashable {
    /// Written by a host or guest.
    case post
    /// Automatic: someone answered, e.g. "Ana is going".
    case rsvp
    /// Automatic: the host changed something, e.g. "Time changed".
    case update
}
