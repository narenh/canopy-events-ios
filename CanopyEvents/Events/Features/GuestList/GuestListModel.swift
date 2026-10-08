import Foundation
import Observation

/// Loads an event's guest list (as you're allowed to see it).
@Observable
final class GuestListModel {
    let eventId: Event.ID
    private(set) var guestList: GuestList?
    var errorMessage: String?

    /// The order sections appear in. `invited` only ever has rows for hosts.
    static let sectionOrder: [RSVPStatus] = [.going, .maybe, .waitlisted, .invited, .notGoing]

    init(eventId: Event.ID) {
        self.eventId = eventId
    }

    func load(from repository: any EventsRepository) async {
        do {
            guestList = try await repository.wholeGuestList(eventId: eventId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
