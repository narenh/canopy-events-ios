import Foundation

/// Sample activity walls: people's posts plus the server's own entries.
/// `canDelete` is worked out per viewer by the mock repository.
enum MockWall {
    static var entries: [Event.ID: [WallEntry]] {
        let p = MockPeople.self
        let rooftopStart = MockDate.at(days: 3, hour: 19, minute: 30)
        let rooftopTime = WallEntryDetails(
            startsAt: rooftopStart, endsAt: rooftopStart.addingTimeInterval(4 * 60 * 60), timeZone: MockEvents.pacific
        )
        return [
            MockEvents.rooftopId: [
                entry("1", .post, p.ana, "Bring a jacket, it gets windy up there!", minutesAgo: 60 * 26),
                entry("2", .going, p.ben, minutesAgo: 60 * 20),
                entry("3", .post, p.chloe, "Can I bring dessert? Thinking tiramisu.", minutesAgo: 60 * 5),
                entry("4", .post, p.ana, "Yes please!", minutesAgo: 60 * 4),
                entry("5", .timeChanged, p.ana, details: rooftopTime, minutesAgo: 60 * 3),
            ],
            MockEvents.birthdayId: [
                entry("6", .cohostAdded, p.ben, minutesAgo: 60 * 48),
                entry("7", .post, p.ben, "I've got the speaker and a giant blanket.", minutesAgo: 60 * 30),
                entry("8", .going, p.hana, minutesAgo: 60 * 8),
            ],
            MockEvents.karaokeId: [
                entry("9", .cancelled, p.jules, minutesAgo: 300),
                entry("10", .post, p.jules, "Sorry all, the venue double-booked us. Rescheduling soon!", minutesAgo: 290),
            ],
            MockEvents.dumplingId: [
                entry("11", .post, MockPeople.maya.person, "Thank you Ana, best dumplings ever.", minutesAgo: 60 * 24 * 8),
            ],
        ]
    }

    /// Where the backend's own entry ids start, after the seed's.
    static let firstNewId = 100

    private static func entry(
        _ id: String, _ type: WallEntryType, _ person: Person, _ text: String? = nil,
        details: WallEntryDetails? = nil, minutesAgo: Int
    ) -> WallEntry {
        WallEntry(id: id, type: type, createdAt: MockDate.ago(minutes: minutesAgo), person: person,
                  text: text, details: details, canDelete: false)
    }
}
