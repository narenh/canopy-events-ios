import Foundation

/// An event, as the signed-in person sees it. Matches the API's `Event`
/// schema; `viewer`, `counts` and `friendsGoing` are worked out by the
/// server for whoever is asking.
///
/// `capacity`, `spotsLeft`, `plusOnesAllowed` and `coverImageUrl` are
/// planned (v1 steps 2 and 4) but not in the API spec yet, so their names
/// are our best guess. See ARCHITECTURE.md, "Mock vs real".
nonisolated struct Event: Codable, Hashable, Identifiable {
    var id: String
    /// The link to share: `https://events.canopysf.com/e/<id>`.
    var url: URL
    var title: String
    var description: String?
    var startsAt: Date
    var endsAt: Date?
    /// IANA time zone, e.g. "America/Los_Angeles". Show times in it.
    var timeZone: String
    var locationName: String?
    var locationAddress: String?
    /// True when there's an address you'd see once signed in.
    var locationAddressHidden: Bool
    var guestListVisibility: GuestListVisibility
    var status: EventStatus
    var cancelledAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var hosts: [Host]
    var counts: RSVPCounts
    var viewer: Viewer?
    /// Only on a single event (not in lists).
    var friendsGoing: FriendsGoing?

    /// Maximum going + their plus-ones; nil means no limit.
    var capacity: Int?
    /// Spots still open; nil when there's no capacity.
    var spotsLeft: Int?
    /// How many plus-ones each RSVP may bring (0 = none).
    var plusOnesAllowed: Int
    var coverImageUrl: URL?
}

extension Event {
    var isCancelled: Bool { status == .cancelled }

    /// The server treats an event without an end as over 6 hours after it starts.
    var effectiveEnd: Date { endsAt ?? startsAt.addingTimeInterval(6 * 60 * 60) }

    var isOver: Bool { effectiveEnd < .now }

    var isFull: Bool { spotsLeft.map { $0 <= 0 } ?? false }

    var eventTimeZone: TimeZone { TimeZone(identifier: timeZone) ?? .current }

    var myStatus: RSVPStatus? { viewer?.rsvp?.status }

    /// Whether you can answer right now (hosts don't RSVP to their own event).
    var canRSVP: Bool { !isCancelled && !isOver && !(viewer?.isHost ?? false) }
}
