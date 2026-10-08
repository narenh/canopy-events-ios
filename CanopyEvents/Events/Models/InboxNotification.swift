import Foundation

/// One entry in your notifications inbox. Not in the API spec yet; the
/// shape is our best guess. Named to avoid clashing with Foundation's
/// `Notification`.
nonisolated struct InboxNotification: Codable, Hashable, Identifiable {
    var id: String
    var kind: NotificationKind
    var eventId: Event.ID?
    var eventTitle: String?
    /// The person who caused it, if any (the host who invited you, etc.).
    var actor: Person?
    var createdAt: Date
    var readAt: Date?

    var isUnread: Bool { readAt == nil }
}
