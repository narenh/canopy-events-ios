import Foundation

/// Co-hosts: the creator adds and takes them off; a co-host can step down.
extension MockEventsRepository {
    func addCohost(eventId: Event.ID, personId cohostId: Person.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isCreator(personId) else { throw APIError.creatorOnly }
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        if record.event.isCancelled { throw APIError.eventCancelled }
        if record.event.isOver { throw APIError.eventOver }
        if cohostId == personId { throw APIError.isCreator }
        guard let person = knownPerson(cohostId) else { throw APIError.personNotFound }
        // Mock: sample people count as verified; accounts go by their flag.
        if backend.account(id: cohostId)?.emailVerified == false { throw APIError.cohostUnverified }
        if record.isHost(cohostId) { return resolved(record) }
        guard record.event.hosts.count - 1 < 10 else { throw APIError.tooManyCohosts }

        // Hosts don't answer: any answer or invitation goes, plus-ones included.
        record.guests.removeAll { $0.person.id == cohostId }
        record.invitedIds.remove(cohostId)
        record.event.hosts.append(Host(person: person, role: .cohost))
        backend.hostedPeople.insert(cohostId)
        let promoted = MockRules.promoteWaitlist(&record)
        save(record)
        removeGoingEntries(eventId: eventId, personId: cohostId)
        addWallEntry(eventId: eventId, type: .cohostAdded, person: person)
        backend.notify(cohostId, .cohostAdded, about: record.event, from: currentUser.person)
        for promotedPerson in promoted {
            addWallEntry(eventId: eventId, type: .offWaitlist, person: promotedPerson)
            backend.notify(promotedPerson.id, .waitlistPromoted, about: record.event, from: nil)
        }
        return resolved(record)
    }

    func removeCohost(eventId: Event.ID, personId cohostId: Person.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isCreator(personId) || cohostId == personId else { throw APIError.creatorOnly }
        guard let host = record.event.hosts.first(where: { $0.person.id == cohostId }), host.role == .cohost else {
            throw APIError.notCohost
        }
        record.event.hosts.removeAll { $0.person.id == cohostId }
        record.guests.append(Guest(person: host.person, status: .invited, guests: 0, guestsOverLimit: false, respondedAt: nil))
        record.invitedIds.insert(cohostId)
        save(record)
        return resolved(record)
    }
}
