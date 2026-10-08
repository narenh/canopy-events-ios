import Foundation
import UserNotifications
import os

/// Shows an inbox entry as a notification on this device, the way a push
/// for it will look: worded by `NotificationWording`, with its category's
/// buttons, its payload, one thread per event, the event's cover as an
/// attachment, and the actor's photo (`CommunicationNotificationBuilder`).
/// The mocked app's stand-in for push, and the test notification.
enum LocalNotifications {
    /// `card` is what the expanded notification draws (an invitation's).
    static func schedule(_ notification: InboxNotification, card: NotificationCard? = nil,
                         after seconds: TimeInterval = 5) async throws {
        guard let shown = await content(for: notification, card: card) else { return }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        try await UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: shown, trigger: trigger)
        )
    }

    /// The test invite (Adam Smith's "Throw Eggs at Karl"), with its card,
    /// as Profile's Debug button and `-mockTestNotification` send it.
    static func scheduleTestInvite(using repository: any EventsRepository, after seconds: TimeInterval = 5) async throws {
        let card = try? await NotificationCard.load(MockEvents.eggsId, from: repository)
        try await schedule(MockNotifications.adamInvite, card: card, after: seconds)
    }

    /// What `schedule` shows: the words, buttons, payload and card, the
    /// cover, and the sender. Nil for a type with nothing to say.
    static func content(for notification: InboxNotification, card: NotificationCard?) async -> UNNotificationContent? {
        guard let payload = NotificationPayload(notification),
              let body = NotificationWording.body(for: notification) else { return nil }
        let content = UNMutableNotificationContent()
        content.title = NotificationWording.title(for: notification)
        content.body = body
        content.sound = .default
        var userInfo: [String: Any] = payload.userInfo
        userInfo[NotificationCard.userInfoKey] = card?.userInfoValue
        content.userInfo = userInfo
        content.threadIdentifier = "event-\(payload.eventId)"
        if let category = NotificationCategory(type: notification.type) {
            content.categoryIdentifier = category.rawValue
        }
        if let event = notification.event, let cover = await NotificationCoverAttachment.make(for: event) {
            content.attachments = [cover]
        }
        var shown: UNNotificationContent = content
        if let actor = notification.actor {
            shown = await CommunicationNotificationBuilder.content(content, from: actor,
                                                                  avatar: await AvatarImage.pngData(for: actor))
        }
        Logger(subsystem: "com.canopysf.CanopyEvents", category: "LocalNotifications").info(
            "scheduling \(notification.type.rawValue, privacy: .public): card \(card == nil ? "none" : "given", privacy: .public), userInfo keys \(shown.userInfo.keys.map { "\($0)" }.sorted(), privacy: .public), attachments \(shown.attachments.count)"
        )
        return shown
    }
}
