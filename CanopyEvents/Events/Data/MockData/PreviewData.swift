import Foundation

/// Ready-made values for `#Preview`s, as Maya (or whoever you pass) would
/// see them. Synchronous, so previews don't need to load anything.
enum PreviewData {
    static func event(_ id: Event.ID = MockEvents.rooftopId, as me: AccountProfile = MockPeople.maya) -> Event {
        let repository = MockEventsRepository(signedInAs: me)
        guard let record = try? repository.record(id) else { fatalError("No mock event \(id)") }
        return repository.resolved(record)
    }

    /// What "Duplicate" starts with for an event `me` hosts.
    static func duplicateDraft(_ id: Event.ID = MockEvents.dragFinaleId, as me: AccountProfile = MockPeople.maya) -> DuplicateDraft {
        let repository = MockEventsRepository(signedInAs: me)
        guard let record = try? repository.record(id) else { fatalError("No mock event \(id)") }
        return repository.draft(copying: record)
    }

    static func guestList(_ id: Event.ID = MockEvents.rooftopId, as me: AccountProfile = MockPeople.maya) -> GuestList {
        let repository = MockEventsRepository(signedInAs: me)
        guard let record = try? repository.record(id) else { fatalError("No mock event \(id)") }
        return MockRules.guestList(record, for: me.person)
    }

    static func wallEntries(_ id: Event.ID = MockEvents.rooftopId) -> [WallEntry] {
        MockWall.entries[id, default: []].sorted { $0.createdAt > $1.createdAt }
    }

    static var friends: [Friend] {
        MockRules.friends(of: MockPeople.maya.person, in: MockEvents.all)
    }
}
