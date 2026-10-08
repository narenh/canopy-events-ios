/// The structured facts of a notification (the API's
/// `Notification.details`); which fields are set depends on its type.
nonisolated struct NotificationDetails: Codable, Hashable {
    /// `event_changed`: the time, the place, or both.
    var changed: [EventChange]?
    /// `wall_post`: the entry's id on the event's wall.
    var entryId: WallEntry.ID?
    /// `wall_post`: the first 200 characters of the post.
    var text: String?
    /// `rsvp`: the latest answer's status.
    var status: RSVPStatus?
}
