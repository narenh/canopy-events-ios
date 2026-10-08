import Foundation

/// The server's rules, reimplemented just enough for the mock: who sees
/// what, how counts and capacity work. Keep it in step with docs/api.md
/// in the canopy-events repo; it goes away when the real API client lands.
enum MockRules {
    /// The event as `me` sees it. Someone a host removed gets the
    /// signed-out view (no address, no friends going), with their
    /// `viewer.rsvp.status` `removed`.
    static func event(_ record: MockEventRecord, for me: Person, friendIds: Set<Person.ID>) -> Event {
        var event = record.event
        event.counts = counts(record)
        event.spotsLeft = event.capacity.map { max(0, $0 - event.counts.total.going) }
        let viewer = viewer(record, for: me)
        event.viewer = viewer

        if viewer.rsvp?.status == .removed {
            event.locationAddressHidden = event.locationAddress != nil
            event.locationAddress = nil
            event.friendsGoing = nil
            return event
        }
        let friends = record.guests
            .filter { $0.status == .going && friendIds.contains($0.person.id) }
            .map(\.person)
        event.friendsGoing = FriendsGoing(
            count: friends.count,
            people: viewer.canSeeGuestList ? Array(friends.prefix(12)) : []
        )
        return event
    }

    static func viewer(_ record: MockEventRecord, for me: Person) -> Viewer {
        let role = record.event.hosts.first { $0.person.id == me.id }?.role
        let rsvp = record.guest(me.id).map {
            RSVP(status: $0.status, guests: $0.guests,
                 guestsOverLimit: $0.guests > record.event.guestsAllowed,
                 invited: record.invitedIds.contains(me.id), respondedAt: $0.respondedAt)
        }
        let status = rsvp?.status
        let canSee = status != .removed
            && (role != nil || record.event.guestListVisibility == .everyone || status?.isAnswer == true)
        return Viewer(
            role: role,
            rsvp: rsvp,
            canEdit: role != nil,
            canSeeGuestList: canSee,
            canPost: role != nil || status?.canPost == true
        )
    }

    /// People per status, their plus-ones, and the two together. Removed
    /// people aren't counted.
    static func counts(_ record: MockEventRecord) -> RSVPCounts {
        var counts = RSVPCounts()
        for guest in record.guests {
            switch guest.status {
            case .invited: counts.invited += 1
            case .going: counts.going += 1; counts.guests.going += guest.guests
            case .maybe: counts.maybe += 1; counts.guests.maybe += guest.guests
            case .notGoing: counts.notGoing += 1
            case .waitlisted: counts.waitlisted += 1; counts.guests.waitlisted += guest.guests
            case .removed: break
            }
        }
        counts.total = GuestCounts(
            going: counts.going + counts.guests.going,
            maybe: counts.maybe + counts.guests.maybe,
            waitlisted: counts.waitlisted + counts.guests.waitlisted
        )
        return counts
    }

    /// A guest-list entry with `guestsOverLimit` worked out.
    static func resolved(_ guest: Guest, in record: MockEventRecord) -> Guest {
        var guest = guest
        guest.guestsOverLimit = guest.guests > record.event.guestsAllowed
        return guest
    }

    /// Moves waitlisted guests to going, earliest first, while they fit:
    /// a big party that doesn't fit is passed over for a smaller one
    /// behind it. A cancelled event promotes nobody. Returns who moved.
    @discardableResult
    static func promoteWaitlist(_ record: inout MockEventRecord) -> [Person] {
        guard let capacity = record.event.capacity, !record.event.isCancelled else { return [] }
        var promoted: [Person] = []
        for index in record.guests.indices where record.guests[index].status == .waitlisted {
            if record.spotsTaken + 1 + record.guests[index].guests <= capacity {
                record.guests[index].status = .going
                promoted.append(record.guests[index].person)
            }
        }
        return promoted
    }
}
