import Foundation

/// Ready-made values for `#Preview`s, as Maya (or whoever you pass) would
/// see them. Synchronous, so previews don't need to load anything.
enum PreviewData {
    static func event(_ id: Event.ID = MockEvents.rooftopId, as me: Me = MockPeople.maya) -> Event {
        let repository = MockEventsRepository(signedInAs: me)
        guard let record = try? repository.record(id) else { fatalError("No mock event \(id)") }
        return repository.resolved(record)
    }

    static func guestList(_ id: Event.ID = MockEvents.rooftopId, as me: Me = MockPeople.maya) -> GuestList {
        let repository = MockEventsRepository(signedInAs: me)
        guard let record = try? repository.record(id) else { fatalError("No mock event \(id)") }
        return MockRules.guestList(record, for: me.person)
    }

    static func posts(_ id: Event.ID = MockEvents.rooftopId) -> [WallPost] {
        MockWallPosts.all.filter { $0.eventId == id }.sorted { $0.createdAt > $1.createdAt }
    }

    static var friends: [Friend] {
        MockRules.friends(of: MockPeople.maya.person, in: MockEvents.all)
    }
}
