import Foundation

/// Creating, editing and cancelling events.
extension MockEventsRepository {
    func createEvent(_ draft: EventDraft) async throws -> Event {
        await pause()
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        let id = String((0..<12).map { _ in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".randomElement()! })
        var event = MockEvents.event(
            id: id, title: draft.title, days: 0, hour: 0, hours: nil,
            locationName: nil, locationAddress: nil, hosts: [MockEvents.host(currentUser.person)]
        )
        event.createdAt = .now
        apply(draft, to: &event)
        records.append(MockEventRecord(event: event, guests: []))
        return resolved(try record(id))
    }

    func updateEvent(id: Event.ID, with draft: EventDraft) async throws -> Event {
        await pause()
        var record = try record(id)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        let old = record.event
        apply(draft, to: &record.event)
        let promoted = MockRules.promoteWaitlist(&record)
        save(record)
        let event = record.event
        if (event.startsAt, event.endsAt, event.timeZone) != (old.startsAt, old.endsAt, old.timeZone) {
            addWallEntry(eventId: id, type: .timeChanged, person: currentUser.person, details: WallEntryDetails(
                startsAt: event.startsAt, endsAt: event.endsAt, timeZone: event.timeZone))
        }
        if (event.locationName, event.locationAddress) != (old.locationName, old.locationAddress) {
            addWallEntry(eventId: id, type: .placeChanged, person: currentUser.person, details: WallEntryDetails(
                locationName: event.locationName, locationAddress: event.locationAddress))
        }
        promoted.forEach { addWallEntry(eventId: id, type: .offWaitlist, person: $0) }
        return resolved(record)
    }

    func cancelEvent(id: Event.ID) async throws -> Event {
        await pause()
        var record = try record(id)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        guard record.event.hosts.first?.person.id == currentUser.id else { throw APIError.creatorOnly }
        record.event.status = .cancelled
        record.event.cancelledAt = .now
        save(record)
        addWallEntry(eventId: id, type: .cancelled, person: currentUser.person)
        for guest in record.guests where [.going, .maybe, .waitlisted].contains(guest.status) {
            backend.notify(guest.person.id, .eventCancelled, about: record.event, from: currentUser.person)
        }
        return resolved(record)
    }

    private func apply(_ draft: EventDraft, to event: inout Event) {
        event.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        event.description = draft.description.isEmpty ? nil : draft.description
        event.startsAt = draft.startsAt
        event.endsAt = draft.endsAt
        event.timeZone = draft.timeZone
        event.locationName = draft.locationName.isEmpty ? nil : draft.locationName
        event.locationAddress = draft.locationAddress.isEmpty ? nil : draft.locationAddress
        event.guestListVisibility = draft.guestListVisibility
        event.capacity = draft.capacity
        event.guestsAllowed = draft.guestsAllowed
        event.updatedAt = .now
    }
}
