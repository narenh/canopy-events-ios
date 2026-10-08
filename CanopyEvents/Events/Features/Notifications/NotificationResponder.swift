import Observation
import UserNotifications

/// The notification center's delegate: answers an invite from its Going /
/// Can't Go buttons (in the background, through the signed-in person's
/// repository), opens the event when a notification is tapped, and shows
/// banners while the app is open. Set as the delegate at launch, so a tap
/// that launches the app is caught.
@Observable
final class NotificationResponder: NSObject, UNUserNotificationCenterDelegate {
    /// The event a tapped notification asks to show; `MainTabView` shows it.
    var opening: OpenedEvent?

    @ObservationIgnored private let session: AppSession

    init(session: AppSession) {
        self.session = session
    }

    /// Becomes the delegate and registers the buttons. Call at launch.
    func register() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.setNotificationCategories(NotificationCategory.all)
    }

    // MARK: UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
    ) async {
        let action = response.actionIdentifier
        guard let payload = NotificationPayload(userInfo: response.notification.request.content.userInfo) else { return }
        await respond(to: action, payload: payload)
    }

    /// Sends the answers given on expanded notifications (the extension
    /// queues them in the App Group). Call when the app becomes active.
    func applyQueuedAnswers() async {
        for queued in AnswerQueue.takeAll() {
            guard let action = NotificationAction(rawValue: queued.action) else { continue }
            await answer(action, NotificationPayload(type: .invited, eventId: queued.eventId,
                                                     notificationId: queued.notificationId))
        }
    }

    // MARK: Responding

    func respond(to actionIdentifier: String, payload: NotificationPayload) async {
        if let action = NotificationAction(rawValue: actionIdentifier) {
            await answer(action, payload)
        } else if actionIdentifier == UNNotificationDefaultActionIdentifier {
            opening = OpenedEvent(payload)
        }
    }

    /// Going or Can't Go: the RSVP, then the inbox entry read, then the
    /// lists told to reload. Signed out, it does nothing.
    private func answer(_ action: NotificationAction, _ payload: NotificationPayload) async {
        guard session.isSignedIn else { return }
        let repository = session.repository
        do {
            _ = try await repository.setRSVP(eventId: payload.eventId, status: action.rsvpStatus, guests: 0)
            if let id = payload.notificationId {
                _ = try? await repository.markNotificationsRead(ids: [id])
            }
        } catch {
            // Too late to tell anyone (the app isn't on screen): the event
            // keeps its old answer, and the page shows it next time.
        }
        session.dataChanged()
    }
}
