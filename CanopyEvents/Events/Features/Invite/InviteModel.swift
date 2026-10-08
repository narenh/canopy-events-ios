import Foundation
import Observation

/// Loads what the invite sheet offers (friends with suggestions, your
/// lists and who's on them, your past events, and everyone on this event
/// already), looks people up by phone or @username, narrows the list to a
/// past event's people, and sends. The picking itself is `picker`.
@Observable
final class InviteModel {
    let event: Event
    var picker = InvitePicker()
    /// Your past events but this one, most recent first.
    private(set) var pastEvents: [Event] = []
    private(set) var hasLoaded = false
    private(set) var isSending = false
    /// The lookup for what's typed now, if it's a number or @username.
    private(set) var lookup: InviteLookup?
    /// "Filter by past event"'s choice (nil: everyone), set at once; the
    /// list narrows (`picker.from`) when its people have loaded.
    private(set) var fromId: Event.ID?
    var errorMessage: String?
    /// Each text is looked up once.
    private var lookups: [String: InviteLookup.State] = [:]
    /// Each past event's people are fetched once.
    private var pastPeople: [Event.ID: InvitePicker.PastFilter] = [:]

    init(event: Event, me: Person.ID?) {
        self.event = event
        picker.me = me
    }

    func load(from repository: any EventsRepository) async {
        do {
            async let friends = repository.allFriends()
            async let suggested = repository.suggestedFriends(limit: 30)
            async let lists = repository.lists()
            async let past = repository.allEvents(.past)
            async let onEvent = statuses(from: repository)
            // Friends first, so their line ("Invitation, 3 events together") wins.
            let suggestions = (try? await suggested) ?? []
            for friend in suggestions.map(\.friend) + (try await friends) {
                picker.add(friend.person, detail: InvitePicker.detail(for: friend), isFriendLink: friend.source == .link)
            }
            picker.suggestedIds = suggestions.map(\.id)
            var pickLists: [InvitePicker.PickList] = []
            for list in try await lists {
                let members = try await repository.allListMembers(listId: list.id)
                for member in members { picker.add(member.person, detail: InvitePicker.detail(onList: list.name)) }
                pickLists.append(InvitePicker.PickList(id: list.id, name: list.name, memberIds: members.map(\.id)))
            }
            picker.lists = pickLists
            pastEvents = try await past.filter { $0.id != event.id }
            picker.onEvent = try await onEvent
            picker.dropUnpickable()
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Who's on the event: hosts, everyone invited or answered, the removed.
    private func statuses(from repository: any EventsRepository) async throws -> [Person.ID: InvitePicker.Status] {
        async let guests = repository.wholeGuestList(eventId: event.id)
        async let removed = repository.guestList(eventId: event.id, status: .removed, page: PageRequest(limit: 100))
        var statuses: [Person.ID: InvitePicker.Status] = [:]
        for guest in try await guests.guests + removed.guests { statuses[guest.id] = .rsvp(guest.status) }
        for host in event.hosts { statuses[host.id] = .hosting }
        return statuses
    }

    // MARK: Lookup

    /// For a whole phone number or @username, once they stop typing (the
    /// view calls this in `.task(id:)`, which cancels it as they type on).
    func lookUp(using repository: any EventsRepository) async {
        let typed = picker.query.trimmingCharacters(in: .whitespaces)
        guard let kind = LookupKind(typed) else { lookup = nil; return }
        let key = "\(kind):\(typed.lowercased())"
        if let known = lookups[key] { lookup = InviteLookup(query: typed, state: known); return }
        lookup = InviteLookup(query: typed, state: .looking)
        try? await Task.sleep(for: .milliseconds(450))
        guard !Task.isCancelled else { return }
        let state: InviteLookup.State
        do {
            if let person = try await repository.lookUpPerson(kind.lookup(typed)), person.id != picker.me {
                picker.add(person, detail: InvitePicker.detail(foundBy: kind))
                state = .found(person.id)
            } else {
                state = .none
            }
            lookups[key] = state
        } catch let error as APIError {
            state = .failed(InviteLookup.words(for: error.reason) ?? error.message)
        } catch {
            state = .failed(error.localizedDescription)
        }
        if picker.query.trimmingCharacters(in: .whitespaces) == typed { lookup = InviteLookup(query: typed, state: state) }
    }

    // MARK: Filtering and sending

    /// "Filter by past event": narrows the list to that event's hosts and
    /// its going and maybe guests you can see, ticking nobody; nil goes
    /// back to everyone. Returns the words to read out ("Showing 4 from
    /// Beach bonfire."), or nil.
    func filter(by eventId: Event.ID?, using repository: any EventsRepository) async -> String? {
        fromId = eventId
        guard let eventId, let past = pastEvents.first(where: { $0.id == eventId }) else {
            picker.from = nil
            return nil
        }
        do {
            let from: InvitePicker.PastFilter
            if let known = pastPeople[eventId] {
                from = known
            } else {
                from = try await people(of: past, from: repository)
                pastPeople[eventId] = from
            }
            guard fromId == eventId else { return nil }
            picker.from = from
            return InvitePicker.showing(from)
        } catch {
            if fromId == eventId { fromId = picker.from?.eventId }
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func people(of past: Event, from repository: any EventsRepository) async throws -> InvitePicker.PastFilter {
        async let going = repository.guestList(eventId: past.id, status: .going, page: PageRequest(limit: 100))
        async let maybe = repository.guestList(eventId: past.id, status: .maybe, page: PageRequest(limit: 100))
        let (goingList, maybeList) = try await (going, maybe)
        // Its hosts too: not on its guest list, but they were there.
        let people = past.hosts.map(\.person) + (goingList.guests + maybeList.guests).map(\.person)
        var ids: [Person.ID] = []
        for person in people where person.id != picker.me && !ids.contains(person.id) {
            picker.add(person, detail: InvitePicker.detail(fromEvent: past.title))
            ids.append(person.id)
        }
        return InvitePicker.PastFilter(eventId: past.id, title: past.title, ids: ids, isHidden: !goingList.guestsVisible)
    }

    /// Sends the picked, 100 at a time (what the API takes). Returns how
    /// many were invited, or nil if it stopped on an error.
    func send(using repository: any EventsRepository) async -> Int? {
        let ids = picker.selected.filter(picker.isPickable)
        guard !ids.isEmpty else { return 0 }
        isSending = true
        defer { isSending = false }
        var invited = 0
        do {
            for start in stride(from: 0, to: ids.count, by: 100) {
                let result = try await repository.invite(eventId: event.id, personIds: Array(ids[start..<min(start + 100, ids.count)]))
                invited += result.invited.count
                for person in result.invited { picker.onEvent[person.id] = .rsvp(.invited) }
            }
            return invited
        } catch {
            picker.dropUnpickable()
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
