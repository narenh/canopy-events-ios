import Foundation

/// The server's rules, reimplemented just enough for the mock: who sees
/// what, how counts and capacity work. Keep it in step with
/// docs/decisions.md in the canopy-events repo; it goes away when the
/// real API client lands.
enum MockRules {
    /// The event as `me` sees it.
    static func event(_ record: MockEventRecord, for me: Person, friendIds: Set<Person.ID>) -> Event {
        var event = record.event
        event.counts = counts(record.guests)
        event.spotsLeft = event.capacity.map { max(0, $0 - record.spotsTaken) }
        let viewer = viewer(record, for: me)
        event.viewer = viewer

        let friends = record.guests
            .filter { $0.status == .going && friendIds.contains($0.person.id) }
            .map(\.person)
        event.friendsGoing = FriendsGoing(
            count: friends.count,
            people: viewer.canSeeGuestList ? Array(friends.prefix(12)) : []
        )
        return event
    }

    /// The guest list as `me` may see it: names only when allowed, and
    /// only hosts see people who were invited but haven't answered.
    static func guestList(_ record: MockEventRecord, for me: Person) -> GuestList {
        let viewer = viewer(record, for: me)
        guard viewer.canSeeGuestList else {
            return GuestList(guestsVisible: false, guests: [], counts: counts(record.guests))
        }
        let visible = viewer.isHost ? record.guests : record.guests.filter { $0.status != .invited }
        return GuestList(guestsVisible: true, guests: visible, counts: counts(record.guests))
    }

    static func viewer(_ record: MockEventRecord, for me: Person) -> Viewer {
        let role = record.event.hosts.first { $0.person.id == me.id }?.role
        let rsvp = record.guest(me.id).map {
            RSVP(status: $0.status, guests: $0.guests,
                 invited: record.invitedIds.contains(me.id), respondedAt: $0.respondedAt)
        }
        let hasAnswered = rsvp.map { $0.status != .invited } ?? false
        return Viewer(
            role: role,
            rsvp: rsvp,
            canEdit: role != nil,
            canSeeGuestList: role != nil || record.event.guestListVisibility == .everyone || hasAnswered
        )
    }

    static func counts(_ guests: [Guest]) -> RSVPCounts {
        var counts = RSVPCounts()
        for guest in guests {
            switch guest.status {
            case .invited: counts.invited += 1
            case .going: counts.going += 1
            case .maybe: counts.maybe += 1
            case .notGoing: counts.notGoing += 1
            case .waitlisted: counts.waitlisted += 1
            }
        }
        return counts
    }

    /// Moves waitlisted guests to going, earliest first, while they fit.
    static func promoteWaitlist(_ record: inout MockEventRecord) {
        guard let capacity = record.event.capacity else { return }
        for index in record.guests.indices where record.guests[index].status == .waitlisted {
            if record.spotsTaken + 1 + record.guests[index].guests <= capacity {
                record.guests[index].status = .going
            }
        }
    }
}
