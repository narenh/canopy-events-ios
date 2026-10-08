import Foundation

/// The guest list and answering (RSVP), with the capacity and waitlist rules.
extension MockEventsRepository {
    func guestList(eventId: Event.ID) async throws -> GuestList {
        await pause()
        return MockRules.guestList(try record(eventId), for: currentUser.person)
    }

    func setRSVP(eventId: Event.ID, status: RSVPStatus, guests: Int) async throws -> Event {
        await pause()
        var record = try record(eventId)
        try checkCanAnswer(record)
        guard guests <= record.event.plusOnesAllowed else { throw APIError.tooManyGuests }
        let plusOnes = status == .notGoing ? 0 : guests

        // Take my old answer out first, so my own spot doesn't count against currentUser.
        record.guests.removeAll { $0.person.id == currentUser.id }
        var finalStatus = status
        if status == .going, let capacity = record.event.capacity,
           record.spotsTaken + 1 + plusOnes > capacity {
            finalStatus = .waitlisted
        }
        record.guests.append(Guest(person: currentUser.person, status: finalStatus, guests: plusOnes, respondedAt: .now))
        MockRules.promoteWaitlist(&record)
        save(record)
        if finalStatus == .going {
            addAutomaticPost(eventId: eventId, kind: .rsvp, body: "\(currentUser.shortName) is going")
        }
        for host in record.event.hosts {
            backend.notify(host.person.id, .newRSVP, about: record.event, from: currentUser.person)
        }
        return resolved(record)
    }

    func withdrawRSVP(eventId: Event.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        try checkCanAnswer(record)
        record.guests.removeAll { $0.person.id == currentUser.id }
        if record.invitedIds.contains(currentUser.id) {
            record.guests.append(Guest(person: currentUser.person, status: .invited, guests: 0, respondedAt: nil))
        }
        MockRules.promoteWaitlist(&record)
        save(record)
        return resolved(record)
    }

    private func checkCanAnswer(_ record: MockEventRecord) throws {
        if record.event.isCancelled { throw APIError.eventCancelled }
        if record.event.isOver { throw APIError.eventOver }
        if record.isHost(personId) { throw APIError.hostCannotRSVP }
    }
}
