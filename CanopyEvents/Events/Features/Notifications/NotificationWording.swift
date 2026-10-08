/// How a notification reads: the title (who, or which event) and the
/// line under it, worded from its type as the inbox would. The real
/// server sends its own words; a local notification, and the inbox
/// later, use these.
nonisolated enum NotificationWording {
    static func title(for notification: InboxNotification) -> String {
        switch notification.type {
        case .invited, .wallPost, .cohostAdded:
            notification.actor?.fullName ?? eventTitle(notification)
        default:
            eventTitle(notification)
        }
    }

    static func body(for notification: InboxNotification) -> String? {
        let who = notification.actor?.shortName ?? "Someone"
        let event = eventTitle(notification)
        switch notification.type {
        case .invited:
            // "10/16 · 7p · Throw Eggs at Karl", under the host's name.
            return notification.event.map { NotificationWhen.line(for: $0) } ?? "Invited you to \(event)"
        case .eventChanged:
            let changed = notification.details?.changed ?? []
            let what = changed.contains(.time) && changed.contains(.place) ? "the time and place"
                : changed.contains(.place) ? "the place" : "the time"
            return "\(who) changed \(what)"
        case .eventCancelled: return "\(who) cancelled it"
        case .eventUncancelled: return "It's back on"
        case .cohostAdded: return "Made you a co-host of \(event)"
        case .waitlistPromoted: return "You got a spot! You're going"
        case .wallPost: return "Posted on \(event): \(notification.details?.text ?? "")"
        case .rsvp:
            let others = notification.count - 1
            return others > 0 ? "\(who) and \(others) \(others == 1 ? "other" : "others") answered" : "\(who) answered"
        case .unknown: return nil
        }
    }

    private static func eventTitle(_ notification: InboxNotification) -> String {
        notification.event?.title ?? "An event"
    }
}
