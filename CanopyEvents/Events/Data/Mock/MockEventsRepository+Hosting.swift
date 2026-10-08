import Foundation

/// Creating, editing, cancelling and un-cancelling events, and covers.
extension MockEventsRepository {
    func createEvent(_ draft: EventDraft) async throws -> Event {
        await pause()
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        let id = newEventId()
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
        var changed: [EventChange] = []
        if (event.startsAt, event.endsAt, event.timeZone) != (old.startsAt, old.endsAt, old.timeZone) {
            changed.append(.time)
            addWallEntry(eventId: id, type: .timeChanged, person: currentUser.person, details: WallEntryDetails(
                startsAt: event.startsAt, endsAt: event.endsAt, timeZone: event.timeZone))
        }
        if (event.locationName, event.locationAddress) != (old.locationName, old.locationAddress) {
            changed.append(.place)
            addWallEntry(eventId: id, type: .placeChanged, person: currentUser.person, details: WallEntryDetails(
                locationName: event.locationName, locationAddress: event.locationAddress))
        }
        if !changed.isEmpty {
            notifyEveryoneComing(record, .eventChanged, details: NotificationDetails(changed: changed))
        }
        for person in promoted {
            addWallEntry(eventId: id, type: .offWaitlist, person: person)
            backend.notify(person.id, .waitlistPromoted, about: event, from: nil)
        }
        return resolved(record)
    }

    func cancelEvent(id: Event.ID) async throws -> Event {
        await pause()
        var record = try record(id)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        guard record.isCreator(currentUser.id) else { throw APIError.creatorOnly }
        record.event.status = .cancelled
        record.event.cancelledAt = .now
        save(record)
        addWallEntry(eventId: id, type: .cancelled, person: currentUser.person)
        notifyEveryoneComing(record, .eventCancelled)
        return resolved(record)
    }

    func uncancelEvent(id: Event.ID) async throws -> Event {
        await pause()
        var record = try record(id)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        guard record.isCreator(currentUser.id) else { throw APIError.creatorOnly }
        record.event.status = .active
        record.event.cancelledAt = nil
        let promoted = MockRules.promoteWaitlist(&record)
        save(record)
        addWallEntry(eventId: id, type: .uncancelled, person: currentUser.person)
        notifyEveryoneComing(record, .eventUncancelled)
        for person in promoted {
            addWallEntry(eventId: id, type: .offWaitlist, person: person)
            backend.notify(person.id, .waitlistPromoted, about: record.event, from: nil)
        }
        return resolved(record)
    }

    /// Mock: the bytes aren't kept; the cover becomes a random placeholder.
    func setCover(eventId: Event.ID, imageData: Data) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        guard !imageData.isEmpty else { throw APIError(message: "That isn't an image.", reason: .badImage) }
        guard imageData.count <= 15_000_000 else { throw APIError(message: "Covers are up to 15 MB.", reason: .tooLarge) }
        record.event.coverImageUrl = MockEvents.coverUrl(seed: UUID().uuidString)
        save(record)
        return resolved(record)
    }

    func deleteCover(eventId: Event.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        record.event.coverImageUrl = nil
        save(record)
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
