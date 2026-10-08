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
        let oldStart = record.event.startsAt
        apply(draft, to: &record.event)
        MockRules.promoteWaitlist(&record)
        save(record)
        if record.event.startsAt != oldStart {
            addAutomaticPost(eventId: id, kind: .update, body: "Time changed")
        }
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
        addAutomaticPost(eventId: id, kind: .update, body: "Event cancelled")
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
