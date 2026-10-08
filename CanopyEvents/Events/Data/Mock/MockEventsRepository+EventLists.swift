import Foundation

/// A host's lists on an event: putting one on invites everyone on it (in
/// the list owner's name, skipping opt-outs, hosts and removed guests
/// without a word), and anyone who joins later too.
extension MockEventsRepository {
    func attachList(eventId: Event.ID, listId: OwnedList.ID) async throws -> ListAttached {
        await pause()
        var record = try record(eventId)
        guard record.isHost(personId) else { throw APIError.hostsOnly }
        let list = try ownList(listId)
        if record.event.isCancelled { throw APIError.eventCancelled }
        if record.event.isOver { throw APIError.eventOver }
        if !record.attachedLists.contains(where: { $0.listId == listId }) {
            guard record.attachedLists.count < 10 else { throw APIError.tooManyListsOnEvent }
            record.attachedLists.append(MockAttachedList(listId: listId, attachedAt: .now))
            save(record)
        }
        // Again: anyone on it who isn't invited yet.
        let invited = backend.invite(list.members.map(\.person), to: eventId, by: personId)
        return ListAttached(event: resolved(try self.record(eventId)), invitedCount: invited.count)
    }

    /// Its owner, or the event's creator. Nobody's invitation changes.
    func detachList(eventId: Event.ID, listId: OwnedList.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isHost(personId) else { throw APIError.hostsOnly }
        guard let list = backend.list(id: listId) else { throw APIError.listNotFound }
        let isOn = record.attachedLists.contains { $0.listId == listId }
        if list.ownerId != personId {
            guard isOn else { throw APIError.listNotFound }
            guard record.isCreator(personId) else { throw APIError.notYourList }
        }
        record.attachedLists.removeAll { $0.listId == listId }
        save(record)
        return resolved(record)
    }
}
