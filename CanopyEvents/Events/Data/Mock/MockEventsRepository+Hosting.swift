import Foundation

/// Creating, editing, cancelling, un-cancelling and deleting events.
extension MockEventsRepository {
    func createEvent(_ draft: EventDraft) async throws -> Event {
        await pause()
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        // A copy's original is checked before anything is made.
        let coverSource = try draft.coverFrom.map(coverSource(_:))
        let id = newEventId()
        var event = MockEvents.event(
            id: id, title: draft.title, days: 0, hour: 0, hours: nil,
            locationName: nil, locationAddress: nil, hosts: [MockEvents.host(currentUser.person)]
        )
        event.createdAt = .now
        try apply(draft, to: &event)
        if let coverSource { copyCover(of: coverSource, to: &event) }
        records.append(MockEventRecord(event: event, guests: []))
        backend.hostedPeople.insert(personId)
        return resolved(try record(id))
    }

    func updateEvent(id: Event.ID, with draft: EventDraft) async throws -> Event {
        await pause()
        var record = try record(id)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        let old = record.event
        try apply(draft, to: &record.event)
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

    func deleteEvent(id: Event.ID) async throws {
        await pause()
        let record = try record(id)
        guard record.isCreator(personId) else { throw APIError.creatorOnly }
        records.removeAll { $0.id == id }
        backend.wall[id] = nil
        for owner in backend.inboxes.keys {
            backend.inboxes[owner]?.removeAll { $0.event?.id == id }
        }
    }

    private func apply(_ draft: EventDraft, to event: inout Event) throws {
        if draft.accentHue != nil && !draft.themeGrayscale {
            throw APIError(message: "Only a grey event has its own accent.", reason: .accentNeedsGrayscale)
        }
        guard let startsAt = draft.startsAt else { throw APIError.badStartsAt }
        event.details = try MockDetails.checked(draft.details)
        event.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        event.description = draft.description.isEmpty ? nil : draft.description
        event.startsAt = startsAt
        event.endsAt = draft.endsAt
        event.timeZone = draft.timeZone
        event.locationName = draft.locationName.isEmpty ? nil : draft.locationName
        event.locationAddress = draft.locationAddress.isEmpty ? nil : draft.locationAddress
        event.guestListVisibility = draft.guestListVisibility
        event.capacity = draft.capacity
        event.guestsAllowed = draft.guestsAllowed
        event.themeHue = draft.themeHue
        event.themeGrayscale = draft.themeGrayscale
        event.accentHue = draft.themeGrayscale ? draft.accentHue : nil
        event.updatedAt = .now
    }
}
