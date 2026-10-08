import Foundation

/// Hosts removing someone (and undoing it), and the creator making a new
/// link. Nobody is notified of any of it.
extension MockEventsRepository {
    func removeGuest(eventId: Event.ID, personId removedId: Person.ID) async throws {
        await pause()
        var record = try record(eventId)
        guard record.isHost(personId) else { throw APIError.hostsOnly }
        if record.isHost(removedId) { throw APIError.isHost }
        guard let person = record.guest(removedId)?.person ?? knownPerson(removedId) else {
            throw APIError.personNotFound
        }
        record.guests.removeAll { $0.person.id == removedId }
        record.guests.append(Guest(person: person, status: .removed, guests: 0, guestsOverLimit: false, respondedAt: nil))
        let promoted = MockRules.promoteWaitlist(&record)
        save(record)
        removeGoingEntries(eventId: eventId, personId: removedId)
        for promotedPerson in promoted {
            addWallEntry(eventId: eventId, type: .offWaitlist, person: promotedPerson)
            backend.notify(promotedPerson.id, .waitlistPromoted, about: record.event, from: nil)
        }
    }

    func restoreGuest(eventId: Event.ID, personId removedId: Person.ID) async throws {
        await pause()
        var record = try record(eventId)
        guard record.isHost(personId) else { throw APIError.hostsOnly }
        guard let index = record.guests.firstIndex(where: { $0.person.id == removedId && $0.status == .removed }) else {
            throw APIError.notRemoved
        }
        record.guests[index].status = .invited
        record.guests[index].respondedAt = nil
        record.invitedIds.insert(removedId)
        save(record)
    }

    func makeNewLink(eventId: Event.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isCreator(personId) else { throw APIError.creatorOnly }
        let newId = newEventId()
        record.event.id = newId
        record.event.url = URL(string: "https://events.canopysf.com/e/\(newId)")!
        guard let index = records.firstIndex(where: { $0.id == eventId }) else { throw APIError.eventNotFound }
        records[index] = record
        // Everything else stays, under the new id.
        backend.wall[newId] = backend.wall.removeValue(forKey: eventId)
        for (owner, inbox) in backend.inboxes {
            backend.inboxes[owner] = inbox.map { item in
                var item = item
                if item.event?.id == eventId { item.event = EventSummary(event: record.event) }
                return item
            }
        }
        return resolved(record)
    }
}
