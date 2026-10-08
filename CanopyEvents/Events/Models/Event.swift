import Foundation

/// An event, as the signed-in person sees it (the API's `Event`), in the
/// spec's field order. `counts`, `spotsLeft`, `viewer` and `friendsGoing`
/// are worked out by the server for whoever is asking.
nonisolated struct Event: Codable, Hashable, Identifiable {
    /// 12 characters of base62. Changes if the creator makes a new link.
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
    /// Nil when signed out or removed (see `locationAddressHidden`).
    var locationAddress: String?
    /// True when there's an address you'd see once signed in.
    var locationAddressHidden: Bool
    var guestListVisibility: GuestListVisibility
    /// Plus-ones each answer may bring, 0 to 10.
    var guestsAllowed: Int
    /// The most people going, plus-ones included; nil for no cap.
    var capacity: Int?
    /// `capacity` minus `counts.total.going`, never below 0; nil with no cap.
    var spotsLeft: Int?
    /// A public JPEG; changes with every upload, so cache it by URL.
    var coverImageUrl: URL?
    var status: EventStatus
    var cancelledAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var hosts: [Host]
    var counts: RSVPCounts
    var viewer: Viewer?
    /// Only on a single event (not in lists), and only when signed in.
    var friendsGoing: FriendsGoing?
}

extension Event {
    var isCancelled: Bool { status == .cancelled }

    /// The server treats an event without an end as over 6 hours after it starts.
    var effectiveEnd: Date { endsAt ?? startsAt.addingTimeInterval(6 * 60 * 60) }

    var isOver: Bool { effectiveEnd < .now }

    var isFull: Bool { spotsLeft.map { $0 <= 0 } ?? false }

    var eventTimeZone: TimeZone { TimeZone(identifier: timeZone) ?? .current }

    var myStatus: RSVPStatus? { viewer?.rsvp?.status }

    /// Whether you can answer right now (hosts don't RSVP to their own
    /// event, and a host may have removed you).
    var canRSVP: Bool {
        !isCancelled && !isOver && !(viewer?.isHost ?? false) && myStatus != .removed
    }
}
