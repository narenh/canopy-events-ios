/// Why something landed in your inbox. Mirrors the list in
/// docs/decisions.md ("Notifications, server side").
nonisolated enum NotificationKind: String, Codable, Hashable {
    case invited
    case eventChanged = "event_changed"
    case eventCancelled = "event_cancelled"
    case madeCohost = "made_cohost"
    case offWaitlist = "off_waitlist"
    case wallPost = "wall_post"
    case newRSVP = "new_rsvp"
}
