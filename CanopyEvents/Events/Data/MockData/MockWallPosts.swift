import Foundation

/// Sample activity-wall entries: people's posts plus automatic ones.
/// `canDelete` is worked out per viewer by the mock repository.
enum MockWallPosts {
    static var all: [WallPost] {
        let p = MockPeople.self
        return [
            post("w1", MockEvents.rooftopId, .post, p.ana, "Bring a jacket, it gets windy up there!", minutesAgo: 60 * 26),
            post("w2", MockEvents.rooftopId, .rsvp, p.ben, "Ben O is going", minutesAgo: 60 * 20),
            post("w3", MockEvents.rooftopId, .post, p.chloe, "Can I bring dessert? Thinking tiramisu.", minutesAgo: 60 * 5),
            post("w4", MockEvents.rooftopId, .post, p.ana, "Yes please!", minutesAgo: 60 * 4),
            post("w5", MockEvents.rooftopId, .update, p.ana, "Time changed to 7:30 PM", minutesAgo: 60 * 3),
            post("w6", MockEvents.birthdayId, .post, p.ben, "I've got the speaker and a giant blanket.", minutesAgo: 60 * 30),
            post("w7", MockEvents.birthdayId, .rsvp, p.hana, "Hana S is going", minutesAgo: 60 * 8),
            post("w8", MockEvents.karaokeId, .update, p.jules, "Event cancelled", minutesAgo: 300),
            post("w9", MockEvents.karaokeId, .post, p.jules, "Sorry all, the venue double-booked us. Rescheduling soon!", minutesAgo: 290),
            post("w10", MockEvents.dumplingId, .post, MockPeople.maya.person, "Thank you Ana, best dumplings ever.", minutesAgo: 60 * 24 * 8),
        ]
    }

    private static func post(
        _ id: String, _ eventId: Event.ID, _ kind: WallPostKind, _ author: Person, _ body: String, minutesAgo: Int
    ) -> WallPost {
        WallPost(id: id, eventId: eventId, kind: kind, author: author, body: body,
                 createdAt: MockDate.ago(minutes: minutesAgo), canDelete: false)
    }
}
