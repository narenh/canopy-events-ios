import UserNotifications

/// A button on a notification. Answering an invite from the notification
/// is an RSVP like any other (`setRSVP`, no plus-ones), done in the
/// background without opening the app.
nonisolated enum NotificationAction: String, CaseIterable, Sendable {
    case going = "GOING"
    case notGoing = "NOT_GOING"

    var title: String {
        switch self {
        case .going: "Going"
        case .notGoing: "Can't Go"
        }
    }

    /// The answer the button gives.
    var rsvpStatus: RSVPStatus {
        switch self {
        case .going: .going
        case .notGoing: .notGoing
        }
    }

    /// An SF Symbol beside the title. Neither is destructive: saying no
    /// is a fine answer.
    var systemImage: String {
        switch self {
        case .going: "checkmark.circle.fill"
        case .notGoing: "xmark.circle"
        }
    }

    /// Requires unlocking: an answer is seen by the host and other guests,
    /// so someone holding a locked phone shouldn't be able to give it.
    /// Not `.foreground`: answering doesn't open the app.
    var unAction: UNNotificationAction {
        UNNotificationAction(identifier: rawValue, title: title, options: [.authenticationRequired],
                             icon: UNNotificationActionIcon(systemImageName: systemImage))
    }
}
