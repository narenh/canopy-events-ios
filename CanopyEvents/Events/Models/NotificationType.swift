/// What a notification is about (the API's `Notification.type`). Typed,
/// never a sentence: the app words it ("Ana invited you to Rooftop
/// dinner"), and the push it came with carries the same type.
///
/// The server will add types: any it doesn't know decodes as `unknown`,
/// and the app skips those.
nonisolated enum NotificationType: String, Codable, Hashable {
    /// You were invited. `actor`: the host.
    case invited
    /// It moved, or the place changed. `actor`: the host; `details.changed`.
    case eventChanged = "event_changed"
    /// It's cancelled. `actor`: the host.
    case eventCancelled = "event_cancelled"
    /// It's back on. `actor`: the host.
    case eventUncancelled = "event_uncancelled"
    /// You're a co-host now. `actor`: the creator.
    case cohostAdded = "cohost_added"
    /// You got a spot from the waitlist: you're going. No `actor`.
    case waitlistPromoted = "waitlist_promoted"
    /// A host posted on the wall. `actor`: the host; `details.entryId`, `details.text`.
    case wallPost = "wall_post"
    /// Someone answered your event (hosts). `actor`: the latest to answer;
    /// `details.status`, theirs; `count`, how many answers folded together.
    case rsvp
    /// A type this version of the app doesn't know.
    case unknown

    init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: raw) ?? .unknown
    }
}
