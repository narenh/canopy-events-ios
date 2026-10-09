import Foundation

/// Duplicating an event (docs/api.md, "Duplicating an event"): the draft
/// a copy starts with, and the cover a copy takes from its original.
extension MockEventsRepository {
    /// Any host who may make events: unverified is `email_unverified`
    /// first (as making an event is), anyone else on it or not
    /// `hosts_only`. No times in it; your own lists that were on it.
    func duplicateDraft(eventId: Event.ID) async throws -> DuplicateDraft {
        await pause()
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        let record = try record(eventId)
        guard record.isHost(personId) else { throw APIError.hostsOnly }
        return draft(copying: record)
    }

    /// The draft for a record you host (synchronous, for previews too).
    func draft(copying record: MockEventRecord) -> DuplicateDraft {
        let event = record.event
        let yours = backend.attachedLists(on: record).map(\.list).filter { $0.ownerId == personId }
        return DuplicateDraft(
            title: event.title, description: event.description, timeZone: event.timeZone,
            locationName: event.locationName, locationAddress: event.locationAddress,
            details: event.shownDetails.map(EventDetailInput.init),
            guestListVisibility: event.guestListVisibility, guestsAllowed: event.guestsAllowed, capacity: event.capacity,
            themeHue: event.themeHue, themeGrayscale: event.themeGrayscale, accentHue: event.accentHue,
            coverFrom: event.hasCover ? event.id : nil,
            coverImageUrl: event.coverImageUrl, coverImages: event.coverImages,
            coverHue: event.coverHue, coverGrayscale: event.coverGrayscale,
            lists: yours.map { DuplicateDraftList(id: $0.id, name: $0.name) }
        )
    }

    /// A copy's `coverFrom`, checked: an event (`bad_cover_from`) you host
    /// (`hosts_only`) that still has a cover (`no_cover`).
    func coverSource(_ id: Event.ID) throws -> Event {
        guard let record = records.first(where: { $0.id == id }) else { throw APIError.badCoverFrom }
        guard record.isHost(personId) else { throw APIError.hostsOnly }
        guard record.event.hasCover else { throw APIError.noCover }
        return record.event
    }

    /// The new event gets its own copy of the cover: an uploaded photo is
    /// copied to a file of its own; a picsum or TMDB address can't be
    /// copied here, so the copy keeps it, in its own record either way, so
    /// removing or replacing either cover never touches the other.
    func copyCover(of source: Event, to event: inout Event) {
        var copies: [URL: URL] = [:]
        func copied(_ url: URL) -> URL {
            if let copy = copies[url] { return copy }
            let copy = MockCoverFile.copy(url) ?? url
            copies[url] = copy
            return copy
        }
        event.coverImageUrl = source.coverImageUrl.map(copied)
        event.coverImages = source.coverImages.map { CoverImage(width: $0.width, height: $0.height, url: copied($0.url)) }
        event.coverHue = source.coverHue
        event.coverGrayscale = source.coverGrayscale
    }
}
