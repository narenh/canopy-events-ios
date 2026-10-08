/// A page of your inbox, newest first, with how many are unread (the
/// API's `NotificationList`).
nonisolated struct NotificationList: Codable, Hashable {
    var notifications: [InboxNotification]
    var unreadCount: Int
    /// Pass back for the next page; nil at the end.
    var nextCursor: String?
}
