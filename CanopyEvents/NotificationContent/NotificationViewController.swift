import SwiftUI
import UIKit
import UserNotifications
import UserNotificationsUI
import os

/// The expanded invite notification (`EVENT_INVITE`): the app's card
/// (`NotificationCardView`), drawn from the card the notification carries,
/// with its own Going / Can't Go. An answer goes to the App Group's queue
/// for the app to send when it next becomes active, shows a checkmark,
/// and the notification closes. The system's own buttons are always
/// hidden here (the card has them); they stay on the short look and the
/// Lock Screen. A notification without a readable card gets its title and
/// body instead, with the same buttons.
///
/// The target links UserNotificationsUI explicitly (OTHER_LDFLAGS): the
/// `import` alone is autolinked, and the linker drops it because nothing
/// references a symbol in it, which leaves the extension host unable to
/// find this extension point's context class: an empty view, and
/// `didReceive` never called.
final class NotificationViewController: UIViewController, UNNotificationContentExtension {
    private let log = Logger(subsystem: "com.canopysf.CanopyEvents", category: "NotificationContent")
    private var host: UIHostingController<AnyView>?
    /// What's shown, drawn for a width: redrawn when the width settles.
    private var content: ((CGFloat) -> AnyView)?
    private var drawnWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    func didReceive(_ notification: UNNotification) {
        // First, whatever else happens: the card has its own buttons.
        extensionContext?.notificationActions = []
        let content = notification.request.content
        let eventId = content.userInfo["eventId"] as? String
        let notificationId = content.userInfo["notificationId"] as? String
        log.info("didReceive \(notification.request.identifier, privacy: .public), event \(eventId ?? "none", privacy: .public)")
        switch NotificationCard.read(content.userInfo) {
        case .success(let card):
            showCard(card, answered: nil, notificationId: notificationId)
        case .failure(let problem):
            log.error("no card, showing the title and body: \(problem.description, privacy: .public)")
            showFallback(content, eventId: eventId, answered: nil, notificationId: notificationId)
        }
    }

    // MARK: Showing

    private func showCard(_ card: NotificationCard, answered: String?, notificationId: String?) {
        show { [weak self] width in
            AnyView(NotificationCardView(card: card, answered: answered, width: width) { action in
                self?.answer(action, eventId: card.eventId, notificationId: notificationId) {
                    self?.showCard(card, answered: action, notificationId: notificationId)
                }
            })
        }
    }

    private func showFallback(_ content: UNNotificationContent, eventId: String?, answered: String?, notificationId: String?) {
        show { [weak self] _ in
            AnyView(NotificationFallbackView(
                title: content.title, message: content.body, answered: answered, canAnswer: eventId != nil
            ) { action in
                guard let eventId else { return }
                self?.answer(action, eventId: eventId, notificationId: notificationId) {
                    self?.showFallback(content, eventId: eventId, answered: action, notificationId: notificationId)
                }
            })
        }
    }

    private func show(_ content: @escaping (CGFloat) -> AnyView) {
        self.content = content
        drawnWidth = view.bounds.width
        let root = content(drawnWidth)
        if let host {
            host.rootView = root
            fitToContent()
            return
        }
        let host = UIHostingController(rootView: root)
        // The notification has no safe area to keep out of; an inset here
        // squeezes the card and cuts off the top of its cover.
        host.safeAreaRegions = []
        host.view.backgroundColor = .clear
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
        self.host = host
        fitToContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The notification settles at its width after `didReceive`: draw again for it.
        if let content, let host, abs(view.bounds.width - drawnWidth) > 0.5 {
            drawnWidth = view.bounds.width
            host.rootView = content(drawnWidth)
        }
        fitToContent()
    }

    /// The notification's height: the content's, at the notification's
    /// width. (Its ideal size, with no width, would lose the 3:2 cover.)
    private func fitToContent() {
        guard let host, view.bounds.width > 0 else { return }
        let size = host.sizeThatFits(in: CGSize(width: view.bounds.width, height: .greatestFiniteMagnitude))
        if abs(size.height - preferredContentSize.height) > 0.5 {
            preferredContentSize = CGSize(width: view.bounds.width, height: size.height)
        }
    }

    // MARK: Answering

    private func answer(_ action: String, eventId: String, notificationId: String?, then redraw: @escaping () -> Void) {
        AnswerQueue.add(QueuedAnswer(eventId: eventId, action: action, notificationId: notificationId, answeredAt: .now))
        log.info("answered \(action, privacy: .public) for \(eventId, privacy: .public)")
        withAnimation { redraw() }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(0.9))
            self?.extensionContext?.dismissNotificationContentExtension()
        }
    }
}
