import Foundation

/// Sample inbox entries, per person.
enum MockNotifications {
    static func inbox(for personId: Person.ID) -> [InboxNotification] {
        let p = MockPeople.self
        switch personId {
        case MockPeople.maya.id:
            return [
                item("1", .rsvp, MockEvents.gameNightId, p.isaac, details: NotificationDetails(status: .going),
                     count: 3, minutesAgo: 30),
                item("2", .invited, MockEvents.hikeId, p.chloe, minutesAgo: 120),
                item("3", .eventChanged, MockEvents.rooftopId, p.ana, details: NotificationDetails(changed: [.time]),
                     minutesAgo: 180),
                item("4", .eventCancelled, MockEvents.karaokeId, p.jules, minutesAgo: 300),
                item("5", .invited, MockEvents.potteryId, p.farah, minutesAgo: 60 * 24, read: true),
                item("6", .wallPost, MockEvents.rooftopId, p.ana,
                     details: NotificationDetails(entryId: "1", text: "Bring a jacket, it gets windy up there!"),
                     minutesAgo: 60 * 26, read: true),
                item("7", .waitlistPromoted, MockEvents.dumplingId, nil, minutesAgo: 60 * 24 * 35, read: true),
            ]
        case MockPeople.sam.id:
            return [item("20", .invited, MockEvents.rooftopId, p.ana, minutesAgo: 45)]
        default:
            return []
        }
    }

    /// Karl Marx inviting you to Marxism 101: the test notification.
    static var karlInvite: InboxNotification {
        item("test-karl", .invited, MockEvents.marxismId, MockPeople.karl, minutesAgo: 0)
    }

    private static func item(
        _ id: String, _ type: NotificationType, _ eventId: Event.ID, _ actor: Person?,
        details: NotificationDetails? = nil, count: Int = 1, minutesAgo: Int, read: Bool = false
    ) -> InboxNotification {
        InboxNotification(
            id: id, type: type, createdAt: MockDate.ago(minutes: minutesAgo), read: read, actor: actor,
            event: MockEvents.all.first { $0.id == eventId }.map { EventSummary(event: $0.event) },
            details: details, count: count
        )
    }
}
