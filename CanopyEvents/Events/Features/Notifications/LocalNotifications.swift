import Foundation
import UserNotifications

/// Shows an inbox entry as a notification on this device, the way a push
/// for it will look: worded by `NotificationWording`, with its category's
/// buttons, its payload, one thread per event, the event's cover as an
/// attachment, and the actor's photo (`CommunicationNotificationBuilder`). The mocked app's stand-in for
/// push, and the test notification.
enum LocalNotifications {
    /// `card` is what the expanded notification draws (an invitation's).
    static func schedule(_ notification: InboxNotification, card: NotificationCard? = nil,
                         after seconds: TimeInterval = 5) async throws {
        guard let payload = NotificationPayload(notification),
              let body = NotificationWording.body(for: notification) else { return }
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
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        try await UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: shown, trigger: trigger)
        )
    }
}
