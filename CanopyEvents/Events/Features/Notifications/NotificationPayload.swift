import Foundation

/// What a notification says about itself in its `userInfo`, besides
/// `aps`: the same fields the events server's push message has (lib/push.js:
/// type, notificationId, eventId, eventTitle, actorId), plus the actor's
/// name for the sender's avatar. docs/push-payloads.md has the whole shape.
nonisolated struct NotificationPayload: Hashable, Sendable {
    var type: NotificationType
    var eventId: Event.ID
    /// The inbox entry's id, to mark it read; nil for a local test.
    var notificationId: InboxNotification.ID?
    var eventTitle: String?
    var actorId: Person.ID?
    var actorName: String?

    enum Key {
        static let type = "type"
        static let eventId = "eventId"
        static let notificationId = "notificationId"
        static let eventTitle = "eventTitle"
        static let actorId = "actorId"
        static let actorName = "actorName"
    }

    /// Nil when there's no event to act on.
    init?(userInfo: [AnyHashable: Any]) {
        guard let eventId = userInfo[Key.eventId] as? String, !eventId.isEmpty else { return nil }
        self.eventId = eventId
        type = (userInfo[Key.type] as? String).flatMap(NotificationType.init(rawValue:)) ?? .unknown
        notificationId = (userInfo[Key.notificationId] as? String) ?? (userInfo[Key.notificationId] as? Int).map(String.init)
        eventTitle = userInfo[Key.eventTitle] as? String
        actorId = userInfo[Key.actorId] as? String
        actorName = userInfo[Key.actorName] as? String
    }

    init(type: NotificationType, eventId: Event.ID, notificationId: InboxNotification.ID? = nil,
         eventTitle: String? = nil, actorId: Person.ID? = nil, actorName: String? = nil) {
        self.type = type
        self.eventId = eventId
        self.notificationId = notificationId
        self.eventTitle = eventTitle
        self.actorId = actorId
        self.actorName = actorName
    }

    /// The payload for an inbox entry (what a push for it carries).
    init?(_ notification: InboxNotification) {
        guard let event = notification.event else { return nil }
        self.init(type: notification.type, eventId: event.id, notificationId: notification.id,
                  eventTitle: event.title, actorId: notification.actor?.id, actorName: notification.actor?.fullName)
    }

    var userInfo: [String: String] {
        var info = [Key.type: type.rawValue, Key.eventId: eventId]
        info[Key.notificationId] = notificationId
        info[Key.eventTitle] = eventTitle
        info[Key.actorId] = actorId
        info[Key.actorName] = actorName
        return info
    }
}
