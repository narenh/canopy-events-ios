import Foundation
import Observation

/// The guests sheet's data: the whole guest list as you may see it (and,
/// for hosts, the removed), the tab and search, and a host's Remove and
/// Undo, each followed by fetching it all again.
@Observable
final class GuestsModel {
    let eventId: Event.ID
    let isHost: Bool
    private(set) var tabs: GuestTabs?
    /// Nil until it loads.
    private(set) var guestsVisible: Bool?
    /// The tab chosen; nil for the first there is.
    var chosen: RSVPStatus?
    var query = "" { didSet { tabs?.query = query } }
    /// "Removed Kai Tanaka." / "Kai Tanaka is invited again."
    private(set) var notice: String?
    private(set) var isWorking = false
    var errorMessage: String?

    init(event: Event) {
        eventId = event.id
        isHost = event.viewer?.isHost == true
    }

    func load(from repository: any EventsRepository) async {
        do {
            async let list = repository.wholeGuestList(eventId: eventId)
            async let removed = isHost ? allRemoved(from: repository) : []
            let (guestList, removedGuests) = try await (list, removed)
            guestsVisible = guestList.guestsVisible
            tabs = GuestTabs(guests: guestList.guests, removed: removedGuests, counts: guestList.counts,
                             isHost: isHost, query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Takes someone off the event (the sheet asks first).
    func remove(_ guest: Guest, using repository: any EventsRepository) async -> Bool {
        await change("Removed \(guest.person.fullName).", using: repository) {
            try await repository.removeGuest(eventId: self.eventId, personId: guest.id)
        }
    }

    /// Undo: they're invited again.
    func restore(_ guest: Guest, using repository: any EventsRepository) async -> Bool {
        await change("\(guest.person.fullName) is invited again.", using: repository) {
            try await repository.restoreGuest(eventId: self.eventId, personId: guest.id)
        }
    }

    private func change(_ words: String, using repository: any EventsRepository,
                        _ call: () async throws -> Void) async -> Bool {
        isWorking = true
        defer { isWorking = false }
        do {
            try await call()
            notice = words
            await load(from: repository)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func allRemoved(from repository: any EventsRepository) async throws -> [Guest] {
        var all: [Guest] = []
        var page = PageRequest(limit: 100)
        while true {
            let answer = try await repository.guestList(eventId: eventId, status: .removed, page: page)
            all += answer.guests
            guard let next = answer.nextCursor else { return all }
            page = .after(next, limit: 100)
        }
    }
}
