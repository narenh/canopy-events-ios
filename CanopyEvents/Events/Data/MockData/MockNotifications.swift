import Foundation

/// Sample inbox entries, per person.
enum MockNotifications {
    static func inbox(for personId: Person.ID) -> [InboxNotification] {
        let p = MockPeople.self
        switch personId {
        case MockPeople.maya.id:
            return [
                item("n1", .newRSVP, MockEvents.gameNightId, "Board game night", p.isaac, minutesAgo: 30),
                item("n2", .invited, MockEvents.hikeId, "Sunrise hike at Mt Tam", p.chloe, minutesAgo: 120),
                item("n3", .eventChanged, MockEvents.rooftopId, "Rooftop dinner", p.ana, minutesAgo: 180),
                item("n4", .eventCancelled, MockEvents.karaokeId, "Karaoke for Jules' 30th", p.jules, minutesAgo: 300),
                item("n5", .invited, MockEvents.potteryId, "Pottery workshop", p.farah, minutesAgo: 60 * 24, read: true),
                item("n6", .wallPost, MockEvents.rooftopId, "Rooftop dinner", p.ana, minutesAgo: 60 * 26, read: true),
                item("n7", .offWaitlist, MockEvents.dumplingId, "Dumpling night", p.ana, minutesAgo: 60 * 24 * 35, read: true),
            ]
        case MockPeople.sam.id:
            return [item("n20", .invited, MockEvents.rooftopId, "Rooftop dinner", p.ana, minutesAgo: 45)]
        default:
            return []
        }
    }

    private static func item(
        _ id: String, _ kind: NotificationKind, _ eventId: Event.ID, _ title: String, _ actor: Person,
        minutesAgo: Int, read: Bool = false
    ) -> InboxNotification {
        let date = MockDate.ago(minutes: minutesAgo)
        return InboxNotification(id: id, kind: kind, eventId: eventId, eventTitle: title, actor: actor,
                                 createdAt: date, readAt: read ? date : nil)
    }
}
