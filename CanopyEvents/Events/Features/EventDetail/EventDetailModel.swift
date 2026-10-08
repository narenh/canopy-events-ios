import Foundation
import Observation

/// Loads one event with its guest list and latest wall posts, and
/// answers it. The event page and its sections read from this.
@Observable
final class EventDetailModel {
    let eventId: Event.ID
    private(set) var event: Event?
    private(set) var guestList: GuestList?
    private(set) var latestPosts: [WallPost] = []
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
            async let posts = repository.wallPosts(eventId: eventId)
            self.event = try await event
            self.guestList = try await guestList
            self.latestPosts = Array(try await posts.prefix(2))
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
