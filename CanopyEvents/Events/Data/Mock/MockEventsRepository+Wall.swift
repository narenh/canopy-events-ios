import Foundation

/// The activity wall. Readable by whoever can see the guest list's names;
/// hosts and going, maybe or waitlisted answers post. Hosts can delete
/// anything; authors their own posts.
extension MockEventsRepository {
    func wall(eventId: Event.ID, page: PageRequest) async throws -> Wall {
        await pause()
        let record = try record(eventId)
        let viewer = MockRules.viewer(record, for: currentUser.person)
        guard viewer.canSeeGuestList else {
            return Wall(wallVisible: false, entries: [], canPost: viewer.canPost, nextCursor: nil)
        }
        let removed = Set(record.guests.filter { $0.status == .removed }.map(\.person.id))
        let all = backend.wall[eventId, default: []]
            .filter { $0.type != .post || !removed.contains($0.person?.id ?? "") }
            .sorted { $0.createdAt > $1.createdAt }
            .map { entry in
                var entry = entry
                entry.canDelete = viewer.isHost || (entry.type == .post && entry.person?.id == personId)
                return entry
            }
        let (entries, next) = try MockPaging.page(all, page)
        return Wall(wallVisible: true, entries: entries, canPost: viewer.canPost, nextCursor: next)
    }

    func postToWall(eventId: Event.ID, text: String) async throws -> WallEntry {
        await pause()
        let record = try record(eventId)
        guard MockRules.viewer(record, for: currentUser.person).canPost else { throw APIError.answerFirst }
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...1000).contains(text.count) else { throw APIError.badText }
        var entry = addWallEntry(eventId: eventId, type: .post, person: currentUser.person, text: text)
        entry.canDelete = true
        if record.isHost(personId) {
            notifyEveryoneComing(record, .wallPost, details: NotificationDetails(entryId: entry.id, text: String(text.prefix(200))))
        }
        return entry
    }

    func deleteWallEntry(id: WallEntry.ID, eventId: Event.ID) async throws {
        await pause()
        let record = try record(eventId)
        guard let entry = backend.wall[eventId]?.first(where: { $0.id == id }) else { throw APIError.entryNotFound }
        guard record.isHost(personId) || (entry.type == .post && entry.person?.id == personId) else {
            throw APIError.notYours
        }
        backend.wall[eventId]?.removeAll { $0.id == id }
    }

    /// One of the server's own entries, or a post. Returns it as stored.
    @discardableResult
    func addWallEntry(
        eventId: Event.ID, type: WallEntryType, person: Person,
        text: String? = nil, details: WallEntryDetails? = nil
    ) -> WallEntry {
        let entry = WallEntry(id: backend.nextId(), type: type, createdAt: .now, person: person,
                              text: text, details: details, canDelete: false)
        backend.wall[eventId, default: []].append(entry)
        return entry
    }

    /// Someone has at most one going or off-waitlist entry, gone once
    /// they aren't going.
    func removeGoingEntries(eventId: Event.ID, personId: Person.ID) {
        backend.wall[eventId]?.removeAll {
            ($0.type == .going || $0.type == .offWaitlist) && $0.person?.id == personId
        }
    }
}
