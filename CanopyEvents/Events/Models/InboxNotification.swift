import Foundation

/// One thing in your inbox (the API's `Notification`; named to avoid
/// clashing with Foundation's). Every push you get is here too. `type`
/// says what it is and which of `actor`, `event` and `details` are set.
nonisolated struct InboxNotification: Codable, Hashable, Identifiable {
    /// Digits, e.g. "17".
    var id: String
    var type: NotificationType
    /// When it (or the latest answer folded into it) happened.
    var createdAt: Date
    var read: Bool
    /// The person who caused it: the host, or the latest to answer.
    var actor: Person?
    var event: EventSummary?
    var details: NotificationDetails?
    /// How many answers an unread `rsvp` notification folds together
    /// ("Ana and 3 others answered"); 1 for everything else.
    var count: Int

    /// False for a type this app doesn't know, which it should skip.
    var isKnown: Bool { type != .unknown }
}
