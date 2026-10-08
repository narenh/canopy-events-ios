import Foundation
import Observation

/// Loads one event with its guest list and latest wall entries, answers
/// it, and runs the host's actions. The event page and its sections read
/// from this.
@Observable
final class EventDetailModel {
    /// Changes when the creator makes a new link.
    private(set) var eventId: Event.ID
    private(set) var event: Event?
    /// The first page of the guest list (up to 50), for Attending.
    private(set) var guestList: GuestList?
    private(set) var latestEntries: [WallEntry] = []
    /// False while you can't see the wall.
    private(set) var wallVisible = true
    private(set) var isSaving = false
    /// A line for the host after an action ("New link made...").
    private(set) var hostNotice: String?
    /// Hosts whose invitations you've opted out of (the guest menu).
    private(set) var optedOut: Set<Person.ID> = []
    /// After joining a list from "Get invited next time".
    private(set) var joinedList: ListJoined?
    var errorMessage: String?

    init(eventId: Event.ID) {
        self.eventId = eventId
    }

    /// Loads the event, guest list and wall at the same time.
    func load(from repository: any EventsRepository) async {
        do {
            async let event = repository.event(id: eventId)
            async let guestList = repository.guestList(eventId: eventId, status: nil, page: PageRequest(limit: 50))
            async let wall = repository.wall(eventId: eventId, page: PageRequest(limit: 3))
            self.event = try await event
            self.guestList = try await guestList
            let latest = try await wall
            self.latestEntries = Array(latest.entries.filter(\.isKnown).prefix(2))
            self.wallVisible = latest.wallVisible
            self.optedOut = Set((try? await repository.inviteOptouts().hosts.map(\.id)) ?? [])
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

    /// Runs one of the host's ⋯ actions (`me` is you, for stepping down).
    /// Returns true when the event is gone (deleted), so the page can close.
    func perform(_ action: HostAction, me: Person.ID?, using repository: any EventsRepository) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            switch action {
            case .newLink:
                let moved = try await repository.makeNewLink(eventId: eventId)
                eventId = moved.id
                hostNotice = "New link made. The old one no longer works, so share this one."
            case .cancel:
                _ = try await repository.cancelEvent(id: eventId)
            case .bringBack:
                _ = try await repository.uncancelEvent(id: eventId)
            case .delete:
                try await repository.deleteEvent(id: eventId)
                return true
            case .stepDown:
                guard let me else { return false }
                _ = try await repository.removeCohost(eventId: eventId, personId: me)
            }
            await load(from: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
        return false
    }

    // MARK: The guest menu

    func setMuted(_ muted: Bool, using repository: any EventsRepository) async {
        do {
            event = muted ? try await repository.muteEvent(id: eventId) : try await repository.unmuteEvent(id: eventId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Off the event for good; the page shows it as anyone with the link sees it.
    func leave(using repository: any EventsRepository) async {
        do {
            event = try await repository.leaveEvent(id: eventId)
            await load(from: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setOptedOut(_ optOut: Bool, from host: Person, using repository: any EventsRepository) async {
        do {
            if optOut {
                try await repository.optOutOfInvites(from: host.id)
                optedOut.insert(host.id)
            } else {
                try await repository.optInToInvites(from: host.id)
                optedOut.remove(host.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// After a change made elsewhere (the co-hosts and lists sheets).
    func update(_ event: Event) {
        self.event = event
    }

    /// After the invite sheet sends: "Invited 7 people.", then a reload.
    func invited(_ count: Int, using repository: any EventsRepository) async {
        hostNotice = count > 0 ? InvitePicker.invitedNotice(count) : nil
        await load(from: repository)
    }

    // MARK: Lists

    /// "Get invited next time": joins the list, which invites you to its
    /// other events still to come.
    func joinList(_ list: JoinableList, using repository: any EventsRepository) async {
        isSaving = true
        defer { isSaving = false }
        do {
            joinedList = try await repository.joinList(code: list.code)
            await load(from: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
