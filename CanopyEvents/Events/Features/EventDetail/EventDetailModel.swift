import Foundation
import Observation

/// Loads one event with its going guests and latest wall entries, and
/// answers it. The event page and its sections read from this.
@Observable
final class EventDetailModel {
    let eventId: Event.ID
    private(set) var event: Event?
    private(set) var guestList: GuestList?
    private(set) var latestEntries: [WallEntry] = []
    /// False while you can't see the wall.
    private(set) var wallVisible = true
    private(set) var isSaving = false
    var errorMessage: String?

    init(eventId: Event.ID) {
        self.eventId = eventId
    }

    /// Loads the event, guest list and wall at the same time.
    func load(from repository: any EventsRepository) async {
        do {
            async let event = repository.event(id: eventId)
            async let guestList = repository.guestList(eventId: eventId, status: .going, page: .first)
            async let wall = repository.wall(eventId: eventId, page: PageRequest(limit: 3))
            self.event = try await event
            self.guestList = try await guestList
            let latest = try await wall
            self.latestEntries = Array(latest.entries.filter(\.isKnown).prefix(2))
            self.wallVisible = latest.wallVisible
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Saves your answer, then reloads so counts and the guest list match.
    func answer(_ status: RSVPStatus, guests: Int = 0, using repository: any EventsRepository) async {
        isSaving = true
        defer { isSaving = false }
        do {
            event = try await repository.setRSVP(eventId: eventId, status: status, guests: guests).event
            await load(from: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
