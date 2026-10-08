import Foundation

/// The guest list and answering (RSVP), with the capacity and waitlist rules.
extension MockEventsRepository {
    func guestList(eventId: Event.ID, status: RSVPStatus?, page: PageRequest) async throws -> GuestList {
        await pause()
        let record = try record(eventId)
        if (status == .invited || status == .removed) && !record.isHost(personId) { throw APIError.hostsOnly }
        var list = MockRules.guestList(record, for: currentUser.person, status: status)
        (list.guests, list.nextCursor) = try MockPaging.page(list.guests, page)
        return list
    }

    func setRSVP(eventId: Event.ID, status: RSVPStatus, guests: Int) async throws -> RSVPResult {
        await pause()
        var record = try record(eventId)
        try checkCanAnswer(record)
        let plusOnes = status == .notGoing ? 0 : guests
        guard plusOnes <= record.event.guestsAllowed else { throw APIError.tooManyGuests }
        let old = record.guest(currentUser.id)

        // Take my old answer out first, so my own spot doesn't count against me.
        record.guests.removeAll { $0.person.id == currentUser.id }
        var finalStatus = status
        if status == .going, let capacity = record.event.capacity,
           record.spotsTaken + 1 + plusOnes > capacity {
            // Already going and asking for more than fits: refused, spot kept.
            if old?.status == .going { throw APIError.noRoom }
            finalStatus = .waitlisted
        }
        record.guests.append(Guest(person: currentUser.person, status: finalStatus, guests: plusOnes,
                                   guestsOverLimit: false, respondedAt: .now))
        let promoted = MockRules.promoteWaitlist(&record)
        save(record)
        afterAnswer(record, old: old?.status, new: finalStatus, promoted: promoted)
        return RSVPResult(event: resolved(record), waitlisted: finalStatus == .waitlisted && status == .going)
    }

    func withdrawRSVP(eventId: Event.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        try checkCanAnswer(record)
        let old = record.guest(currentUser.id)
        record.guests.removeAll { $0.person.id == currentUser.id }
        if record.invitedIds.contains(currentUser.id) {
            record.guests.append(Guest(person: currentUser.person, status: .invited, guests: 0,
                                       guestsOverLimit: false, respondedAt: nil))
        }
        let promoted = MockRules.promoteWaitlist(&record)
        save(record)
        afterAnswer(record, old: old?.status, new: nil, promoted: promoted)
        return resolved(record)
    }

    private func checkCanAnswer(_ record: MockEventRecord) throws {
        if record.event.isCancelled { throw APIError.eventCancelled }
        if record.event.isOver { throw APIError.eventOver }
        if record.isHost(personId) { throw APIError.hostCannotRSVP }
        if record.guest(personId)?.status == .removed { throw APIError.removed }
    }

    /// The server's side effects of an answer changing: the wall's "is
    /// going" entries and the hosts' inbox.
    private func afterAnswer(_ record: MockEventRecord, old: RSVPStatus?, new: RSVPStatus?, promoted: [Person]) {
        if new != .going {
            removeGoingEntries(eventId: record.id, personId: personId)
        } else if old != .going {
            addWallEntry(eventId: record.id, type: .going, person: currentUser.person)
        }
        promoted.forEach { addWallEntry(eventId: record.id, type: .offWaitlist, person: $0) }
        if let new, new != old {
            for host in record.event.hosts {
                backend.notify(host.person.id, .newRSVP, about: record.event, from: currentUser.person)
            }
        }
        for person in promoted {
            backend.notify(person.id, .offWaitlist, about: record.event, from: currentUser.person)
        }
    }
}
