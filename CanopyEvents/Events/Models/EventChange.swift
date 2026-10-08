/// What changed about an event, in an `event_changed` notification's
/// `details.changed`: the time, the place, or both.
nonisolated enum EventChange: String, Codable, Hashable {
    case time
    case place
}
