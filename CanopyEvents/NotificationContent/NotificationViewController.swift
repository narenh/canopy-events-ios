import SwiftUI
import UIKit
import UserNotifications
import UserNotificationsUI

/// The expanded invite notification (`EVENT_INVITE`): the app's card
/// (`NotificationCardView`), drawn from the card the notification carries,
/// with its own Going / Can't Go. An answer goes to the App Group's queue
/// for the app to send when it next becomes active, shows a checkmark,
/// and the notification closes. The system's own buttons are hidden here
/// (the card has them), and stay on the short look and the Lock Screen.
final class NotificationViewController: UIViewController, UNNotificationContentExtension {
    private var host: UIHostingController<NotificationCardView>?

    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        guard let card = NotificationCard(userInfo: content.userInfo) else { return }
        extensionContext?.notificationActions = []
        let notificationId = content.userInfo["notificationId"] as? String
        show(card, answered: nil, notificationId: notificationId)
    }

    private func show(_ card: NotificationCard, answered: String?, notificationId: String?) {
        let view = NotificationCardView(card: card, answered: answered) { [weak self] action in
            self?.answer(action, card: card, notificationId: notificationId)
        }
        if let host {
            host.rootView = view
            return
        }
        let host = UIHostingController(rootView: view)
        host.sizingOptions = .preferredContentSize
        host.view.backgroundColor = .clear
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        host.didMove(toParent: self)
        self.host = host
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: any UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        preferredContentSize = container.preferredContentSize
    }

    private func answer(_ action: String, card: NotificationCard, notificationId: String?) {
        AnswerQueue.add(QueuedAnswer(eventId: card.eventId, action: action, notificationId: notificationId,
                                     answeredAt: .now))
        withAnimation { show(card, answered: action, notificationId: notificationId) }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(0.9))
            self?.extensionContext?.dismissNotificationContentExtension()
        }
    }
}
