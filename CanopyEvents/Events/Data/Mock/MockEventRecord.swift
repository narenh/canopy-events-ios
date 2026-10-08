import Foundation

/// What the mock "server" stores for one event: the event's own fields
/// plus everyone's RSVPs (and who a host removed). `MockRules` turns a record into the `Event`
/// and `GuestList` a particular person is allowed to see, the way the
/// real server will.
struct MockEventRecord {
    /// The event's fields. `counts`, `viewer`, `spotsLeft` and
    /// `friendsGoing` are filled in per viewer by `MockRules`.
    var event: Event
    /// Everyone on the guest list (hosts aren't on it), oldest first.
    var guests: [Guest]
    /// People a host invited. Withdrawing an answer leaves them `invited`.
    var invitedIds: Set<Person.ID> = []

    var id: Event.ID { event.id }

    func isHost(_ personId: Person.ID) -> Bool {
        event.hosts.contains { $0.person.id == personId }
    }

    func isCreator(_ personId: Person.ID) -> Bool {
        event.hosts.contains { $0.person.id == personId && $0.role == .creator }
    }

    func guest(_ personId: Person.ID) -> Guest? {
        guests.first { $0.person.id == personId }
    }

    /// Going guests plus their plus-ones: what counts against capacity.
    var spotsTaken: Int {
        guests.filter { $0.status == .going }.reduce(0) { $0 + 1 + $1.guests }
    }
}
