import UserNotifications

/// The kinds of notification that carry buttons, by the `aps.category`
/// the server sends (docs/push-payloads.md). Registered at launch, before
/// any notification arrives.
nonisolated enum NotificationCategory: String, CaseIterable, Sendable {
    /// "Adam Smith · 10/16 · 7p · Throw Eggs at Karl": Going, Can't Go.
    /// Exactly two: there's no Maybe, on purpose.
    case eventInvite = "EVENT_INVITE"

    var actions: [NotificationAction] {
        switch self {
        case .eventInvite: [.going, .notGoing]
        }
    }

    /// The category for a notification type, if it has buttons.
    init?(type: NotificationType) {
        switch type {
        case .invited: self = .eventInvite
        default: return nil
        }
    }

    var unCategory: UNNotificationCategory {
        UNNotificationCategory(identifier: rawValue, actions: actions.map(\.unAction), intentIdentifiers: [],
                               options: [])
    }

    /// Every category, for `UNUserNotificationCenter.setNotificationCategories`.
    static var all: Set<UNNotificationCategory> { Set(allCases.map(\.unCategory)) }
}
