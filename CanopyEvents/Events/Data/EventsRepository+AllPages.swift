/// Following `nextCursor` to the end, for screens that show a whole list.
extension EventsRepository {
    /// Every event in one of your lists.
    func allEvents(_ list: EventListKind) async throws -> [Event] {
        var events: [Event] = []
        var page = PageRequest.first
        while true {
            let answer = try await self.events(list, page: page)
            events += answer.events
            guard let next = answer.nextCursor else { return events }
            page = .after(next)
        }
    }

    /// All your friends.
    func allFriends() async throws -> [Friend] {
        var friends: [Friend] = []
        var page = PageRequest.first
        while true {
            let answer = try await self.friends(page: page)
            friends += answer.friends
            guard let next = answer.nextCursor else { return friends }
            page = .after(next)
        }
    }

    /// Everyone on one of your lists, newest first.
    func allListMembers(listId: OwnedList.ID) async throws -> [ListMember] {
        var members: [ListMember] = []
        var page = PageRequest(limit: 100)
        while true {
            let answer = try await listMembers(listId: listId, page: page)
            members += answer.members
            guard let next = answer.nextCursor else { return members }
            page = .after(next, limit: 100)
        }
    }

    /// The whole guest list: every page's guests, with the latest counts.
    func wholeGuestList(eventId: Event.ID) async throws -> GuestList {
        var list = try await guestList(eventId: eventId, status: nil, page: .first)
        while let next = list.nextCursor {
            let answer = try await guestList(eventId: eventId, status: nil, page: .after(next))
            list.guests += answer.guests
            list.counts = answer.counts
            list.nextCursor = answer.nextCursor
        }
        return list
    }
}
