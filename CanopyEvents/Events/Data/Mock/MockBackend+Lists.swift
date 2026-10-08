import Foundation

/// The lists rules (docs/api.md, "Lists"): joining, and the invitations a
/// list makes, in its owner's name, when it's put on an event and when
/// someone joins it later.
extension MockBackend {
    func list(id: String) -> MockListRecord? {
        lists.first { $0.id == id }
    }

    func list(code: String) -> MockListRecord? {
        lists.first { $0.code == code }
    }

    /// Replaces a stored list with a changed copy.
    func save(_ list: MockListRecord) {
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else { return }
        lists[index] = list
    }

    /// Invites `people` to an event in `hostId`'s name, the way `POST
    /// .../invites` does, except that everyone it can't invite is skipped
    /// without a word: the event's hosts, anyone on its guest list already
    /// (a host's removal included), and anyone who opted out of `hostId`'s
    /// invitations. Each invitee is told and becomes a friend both ways.
    /// Returns who was invited.
    @discardableResult
    func invite(_ people: [Person], to eventId: Event.ID, by hostId: Person.ID, quietly: Bool = false, at date: Date = .now) -> [Person] {
        guard var record = records.first(where: { $0.id == eventId }), let host = person(hostId) else { return [] }
        var invited: [Person] = []
        for person in people where !record.isHost(person.id) && record.guest(person.id) == nil
            && !inviteOptouts[person.id, default: []].contains(hostId) {
            record.guests.append(Guest(person: person, status: .invited, guests: 0, guestsOverLimit: false, respondedAt: nil))
            record.invitedIds.insert(person.id)
            invited.append(person)
        }
        guard let index = records.firstIndex(where: { $0.id == eventId }) else { return [] }
        records[index] = record
        for person in invited {
            if !quietly { notify(person.id, .invited, about: record.event, from: host) }
            befriend(hostId, person.id, source: .invite, at: date)
            befriend(person.id, hostId, source: .invite, at: date)
        }
        return invited
    }

    /// Puts `person` on the list and invites them to every event still to
    /// come that the list is on (and whose hosts include its owner).
    /// Returns how many events. Already on it changes nothing.
    func join(_ person: Person, listId: String) -> Int {
        guard var list = list(id: listId), !list.hasMember(person.id) else { return 0 }
        list.members.append(ListMember(person: person, joinedAt: .now))
        save(list)
        let events = records.filter { record in
            record.isUpcoming && record.isHost(list.ownerId) && record.attachedLists.contains { $0.listId == listId }
        }
        return events.filter { !invite([person], to: $0.id, by: list.ownerId).isEmpty }.count
    }

    /// The seed's lists on events invite their people, as attaching them
    /// did; nobody is told (it all happened before the app opened).
    func inviteSeedLists() {
        for record in records {
            for attached in record.attachedLists {
                guard let list = list(id: attached.listId) else { continue }
                invite(list.members.map(\.person), to: record.id, by: list.ownerId, quietly: true, at: attached.attachedAt)
            }
        }
    }
}
