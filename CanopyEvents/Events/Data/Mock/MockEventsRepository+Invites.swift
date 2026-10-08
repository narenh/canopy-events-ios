import Foundation

/// Hosts inviting people by id. Each invitee gets an inbox entry.
extension MockEventsRepository {
    func invite(eventId: Event.ID, personIds: [Person.ID]) async throws -> InviteResult {
        await pause()
        var record = try record(eventId)
        guard record.isHost(personId) else { throw APIError.hostsOnly }
        if record.event.isCancelled { throw APIError.eventCancelled }
        if record.event.isOver { throw APIError.eventOver }

        var result = InviteResult(invited: [], skipped: [])
        for id in personIds {
            if record.isHost(id) {
                result.skipped.append(SkippedInvite(personId: id, reason: "is_host"))
            } else if record.guest(id) != nil {
                result.skipped.append(SkippedInvite(personId: id, reason: "already_on_list"))
            } else if let person = knownPerson(id) {
                record.guests.append(Guest(person: person, status: .invited, guests: 0, guestsOverLimit: false, respondedAt: nil))
                record.invitedIds.insert(id)
                result.invited.append(person)
            } else {
                result.skipped.append(SkippedInvite(personId: id, reason: "not_found"))
            }
        }
        save(record)
        for person in result.invited {
            backend.notify(person.id, .invited, about: record.event, from: currentUser.person)
        }
        return result
    }

    /// Anyone the mock world knows: the sample people and every account.
    private func knownPerson(_ id: Person.ID) -> Person? {
        MockPeople.everyone.first { $0.id == id }
            ?? backend.account(id: id)?.person
    }
}
