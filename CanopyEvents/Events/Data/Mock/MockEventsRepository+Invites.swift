import Foundation

/// Hosts inviting people by id (each invitee gets an inbox entry), and
/// taking an invitation back.
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
                result.skipped.append(SkippedInvite(personId: id, reason: .isHost))
            } else if record.guest(id)?.status == .removed {
                result.skipped.append(SkippedInvite(personId: id, reason: .removed))
            } else if record.guest(id) != nil {
                result.skipped.append(SkippedInvite(personId: id, reason: .alreadyOnList))
            } else if let person = knownPerson(id) {
                record.guests.append(Guest(person: person, status: .invited, guests: 0, guestsOverLimit: false, respondedAt: nil))
                record.invitedIds.insert(id)
                result.invited.append(person)
            } else {
                result.skipped.append(SkippedInvite(personId: id, reason: .notFound))
            }
        }
        save(record)
        for person in result.invited {
            backend.notify(person.id, .invited, about: record.event, from: currentUser.person)
        }
        return result
    }

    func uninvite(eventId: Event.ID, personId invitee: Person.ID) async throws {
        await pause()
        var record = try record(eventId)
        guard record.isHost(personId) else { throw APIError.hostsOnly }
        guard record.invitedIds.contains(invitee), let guest = record.guest(invitee) else { throw APIError.notInvited }
        guard guest.status == .invited else { throw APIError.alreadyResponded }
        record.guests.removeAll { $0.person.id == invitee }
        record.invitedIds.remove(invitee)
        save(record)
    }
}
