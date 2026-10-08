import Foundation

extension MockRules {
    /// Whether an event belongs in one of `me`'s event lists.
    static func record(_ record: MockEventRecord, isIn list: EventListKind, for me: Person) -> Bool {
        let event = record.event
        let status = record.guest(me.id)?.status
        switch list {
        case .all:
            // Each event once: hosting, upcoming and invitations together.
            return [.hosting, .upcoming, .invitations].contains { Self.record(record, isIn: $0, for: me) }
        case .hosting:
            return record.isHost(me.id) && !event.isOver
        case .upcoming:
            return [.going, .maybe, .waitlisted].contains(status) && !event.isOver
        case .invitations:
            return status == .invited && !event.isOver && !event.isCancelled
        case .past:
            return event.isOver && (record.isHost(me.id) || status == .going || status == .maybe)
        case .declined:
            return status == .notGoing && !event.isOver && !event.isCancelled
        }
    }

    /// The people you were at an event with: both there (a host, or
    /// going) on an event that has started and wasn't cancelled. Most
    /// events in common first. (The whole friends list adds the people
    /// added, linked or invited: `MockBackend.friends(of:)`.)
    static func friends(of me: Person, in records: [MockEventRecord]) -> [Friend] {
        var friends: [Person.ID: Friend] = [:]
        for record in records where record.event.startsAt < .now && !record.event.isCancelled {
            let present = record.event.hosts.map(\.person)
                + record.guests.filter { $0.status == .going }.map(\.person)
            guard present.contains(where: { $0.id == me.id }) else { continue }
            for person in present where person.id != me.id {
                var friend = friends[person.id]
                    ?? Friend(person: person, source: .sharedEvents, eventsInCommon: 0, lastTogetherAt: nil)
                friend.eventsInCommon += 1
                friend.lastTogetherAt = max(friend.lastTogetherAt ?? .distantPast, record.event.startsAt)
                friends[person.id] = friend
            }
        }
        return friends.values.sorted {
            ($0.eventsInCommon, $0.lastTogetherAt ?? .distantPast) > ($1.eventsInCommon, $1.lastTogetherAt ?? .distantPast)
        }
    }
}
