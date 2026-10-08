import Foundation
import Observation

/// Picking friends to invite to an event you host. Friends already on
/// the guest list (invited or answered) can't be picked again.
@Observable
final class InviteFriendsModel {
    let eventId: Event.ID
    private(set) var friends: [Friend] = []
    private(set) var alreadyOnList: Set<Person.ID> = []
    private(set) var hasLoaded = false
    private(set) var isSending = false
    var selected: Set<Person.ID> = []
    var errorMessage: String?

    init(eventId: Event.ID) {
        self.eventId = eventId
    }

    func load(from repository: any EventsRepository) async {
        do {
            async let friends = repository.friends()
            async let guestList = repository.guestList(eventId: eventId)
            self.friends = try await friends
            alreadyOnList = Set(try await guestList.guests.map(\.person.id))
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggle(_ friend: Friend) {
        guard !alreadyOnList.contains(friend.id) else { return }
        if selected.contains(friend.id) {
            selected.remove(friend.id)
        } else {
            selected.insert(friend.id)
        }
    }

    /// Sends the invites. Returns true when done.
    func send(using repository: any EventsRepository) async -> Bool {
        isSending = true
        defer { isSending = false }
        do {
            _ = try await repository.invite(eventId: eventId, personIds: Array(selected))
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
