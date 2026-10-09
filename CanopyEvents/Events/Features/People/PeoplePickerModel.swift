import Foundation
import Observation

/// Loads what a picker offers (friends with suggestions, your lists and
/// who's on them, your past events, and who's there already), looks people
/// up by phone or @username, and narrows the list to a past event's
/// people (`+Lookup`); then invites them, adds them to the list, or saves
/// them as a list (`+Sending`). The picking itself is `picker`. The invite
/// sheet and a list's "Add people" each have one.
@Observable
final class PeoplePickerModel {
    /// Who the picked are for.
    enum Target {
        /// Inviting to this event: everyone on it is there already.
        case event(Event)
        /// Adding to this list of yours: everyone on it is there already,
        /// and it isn't offered among "Your lists".
        case list(OwnedList)
    }

    let target: Target
    var picker = PeoplePicker()
    /// Your past events but this one, most recent first.
    private(set) var pastEvents: [Event] = []
    private(set) var hasLoaded = false
    var isSending = false
    /// The lookup for what's typed now, if it's a number or @username.
    var lookup: PickerLookup?
    /// "Filter by past event"'s choice (nil: everyone), set at once; the
    /// list narrows (`picker.from`) when its people have loaded.
    var fromId: Event.ID?
    /// A line after "Save as list" ("Saved 5 people to Regulars.").
    var notice: String?
    var errorMessage: String?
    /// Each text is looked up once (`+Lookup`).
    var lookups: [String: PickerLookup.State] = [:]
    /// Each past event's people are fetched once (`+Lookup`).
    var pastPeople: [Event.ID: PeoplePicker.PastFilter] = [:]

    init(target: Target, me: Person.ID?) {
        self.target = target
        picker.me = me
        if case .list = target { picker.kind = .list }
    }

    private var eventId: Event.ID? {
        if case .event(let event) = target { event.id } else { nil }
    }

    private var listId: OwnedList.ID? {
        if case .list(let list) = target { list.id } else { nil }
    }

    func load(from repository: any EventsRepository) async {
        do {
            async let friends = repository.allFriends()
            async let suggested = repository.suggestedFriends(limit: 30)
            async let lists = repository.lists()
            async let past = repository.allEvents(.past)
            async let already = taken(from: repository)
            // Friends first, so their line ("Invitation, 3 events together") wins.
            let suggestions = (try? await suggested) ?? []
            for friend in suggestions.map(\.friend) + (try await friends) {
                picker.add(friend.person, detail: PeoplePicker.detail(for: friend), isFriendLink: friend.source == .link)
            }
            picker.suggestedIds = suggestions.map(\.id)
            var pickLists: [PeoplePicker.PickList] = []
            for list in try await lists where list.id != listId {
                let members = try await repository.allListMembers(listId: list.id)
                for member in members { picker.add(member.person, detail: PeoplePicker.detail(onList: list.name)) }
                pickLists.append(PeoplePicker.PickList(id: list.id, name: list.name, memberIds: members.map(\.id)))
            }
            picker.lists = pickLists
            pastEvents = try await past.filter { $0.id != eventId }
            let (statuses, people) = try await already
            for person in people { picker.add(person, detail: "") }
            picker.taken = statuses
            picker.dropUnpickable()
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Who's there already, and anyone of them the sheet should list: for
    /// an event, its hosts, everyone invited or answered, and the removed;
    /// for a list, everyone on it (listed, greyed "On list").
    func taken(from repository: any EventsRepository) async throws -> ([Person.ID: PeoplePicker.Status], [Person]) {
        switch target {
        case .event(let event):
            async let guests = repository.wholeGuestList(eventId: event.id)
            async let removed = repository.guestList(eventId: event.id, status: .removed, page: PageRequest(limit: 100))
            var statuses: [Person.ID: PeoplePicker.Status] = [:]
            for guest in try await guests.guests + removed.guests { statuses[guest.id] = .rsvp(guest.status) }
            for host in event.hosts { statuses[host.id] = .hosting }
            return (statuses, [])
        case .list(let list):
            let members = try await repository.allListMembers(listId: list.id)
            return (Dictionary(members.map { ($0.id, .onList) }, uniquingKeysWith: { first, _ in first }), members.map(\.person))
        }
    }
}
