import Foundation

/// A guest's own controls on an event: mute it, leave it, and opt out of
/// a host's invitations.
extension MockEventsRepository {
    func muteEvent(id: Event.ID) async throws -> Event {
        try await setMuted(true, id)
    }

    func unmuteEvent(id: Event.ID) async throws -> Event {
        try await setMuted(false, id)
    }

    /// Off the event for good: the invitation or answer, the "going" on
    /// the wall, the inbox entries and the mute all go; a spot goes to the
    /// waitlist. Nobody is told. The link still works.
    func leaveEvent(id: Event.ID) async throws -> Event {
        await pause()
        var record = try record(id)
        try checkOnEvent(record)
        record.guests.removeAll { $0.person.id == personId }
        record.invitedIds.remove(personId)
        record.mutedIds.remove(personId)
        let promoted = MockRules.promoteWaitlist(&record)
        save(record)
        removeGoingEntries(eventId: id, personId: personId)
        backend.inboxes[personId]?.removeAll { $0.event?.id == id }
        for person in promoted {
            addWallEntry(eventId: id, type: .offWaitlist, person: person)
            backend.notify(person.id, .waitlistPromoted, about: record.event, from: nil)
        }
        return resolved(record)
    }

    func inviteOptouts() async throws -> InviteOptouts {
        await pause()
        return InviteOptouts(hosts: backend.inviteOptouts[personId, default: []].compactMap(backend.person))
    }

    func optOutOfInvites(from hostId: Person.ID) async throws {
        await pause()
        guard hostId != personId else { throw APIError.isYou }
        guard backend.person(hostId) != nil else { throw APIError.personNotFound }
        if !backend.inviteOptouts[personId, default: []].contains(hostId) {
            backend.inviteOptouts[personId, default: []].append(hostId)
        }
    }

    func optInToInvites(from hostId: Person.ID) async throws {
        await pause()
        guard hostId != personId else { throw APIError.isYou }
        backend.inviteOptouts[personId]?.removeAll { $0 == hostId }
    }

    // MARK: Helpers

    private func setMuted(_ muted: Bool, _ id: Event.ID) async throws -> Event {
        await pause()
        var record = try record(id)
        if muted {
            try checkOnEvent(record)
            record.mutedIds.insert(personId)
        } else {
            record.mutedIds.remove(personId)
        }
        save(record)
        return resolved(record)
    }

    /// A guest on it: not a host, invited or answered, not removed.
    private func checkOnEvent(_ record: MockEventRecord) throws {
        if record.isHost(personId) { throw APIError.isHostOwnEvent }
        guard let status = record.guest(personId)?.status else { throw APIError.notOnEvent }
        if status == .removed { throw APIError.removed }
    }
}
