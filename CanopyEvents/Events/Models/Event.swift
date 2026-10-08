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
    /// The host's extra fields, in order (up to 10). Signed out or
    /// removed, parking, stay and phone are left out.
    var details: [EventDetail]
    /// How many details are left out until you sign in.
    var hiddenDetails: Int
    var guestListVisibility: GuestListVisibility
    /// Plus-ones each answer may bring, 0 to 10.
    var guestsAllowed: Int
    /// The most people going, plus-ones included; nil for no cap.
    var capacity: Int?
    /// `capacity` minus `counts.total.going`, never below 0; nil with no cap.
    var spotsLeft: Int?
    /// The full-size cover (up to 1600 px), a public JPEG, for link
    /// previews; changes with every upload. To draw it, use `coverImages`.
    var coverImageUrl: URL?
    /// Every size of the cover, narrowest first, the last at
    /// `coverImageUrl`. Empty with no cover (and briefly for an old one:
    /// use `coverImageUrl` then).
    var coverImages: [CoverImage]
    /// The page's color as a hue, 0–359; nil for Canopy green. Ignored
    /// while `themeGrayscale` is true. Use `theme`.
    var themeHue: Int?
    /// No color at all: a neutral grey page.
    var themeGrayscale: Bool
    /// A grey event's accent: a hue, or nil for white. Always nil while
    /// `themeGrayscale` is false (the accent follows `themeHue` then).
    var accentHue: Int?
    /// The hue that matches the cover photo, a suggestion for `themeHue`
    /// (an upload never changes the theme). Nil with no cover, for a grey
    /// photo, or for a cover from before this existed.
    var coverHue: Int?
    /// The cover is essentially grey, so its match is `themeGrayscale`.
    var coverGrayscale: Bool
    var status: EventStatus
    var cancelledAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var hosts: [Host]
    var counts: RSVPCounts
    var viewer: Viewer?
    /// Only on a single event (not in lists), and only when signed in.
    var friendsGoing: FriendsGoing?
    /// Only on a single event, and only to its hosts: the lists on it, in
    /// the order they were put on. Nil for anyone else.
    var hostLists: [HostList]? = nil
    /// Only on a single event: a list on it you could join ("Get invited
    /// next time"). Nil for hosts, someone a host removed, or none.
    var joinableList: JoinableList? = nil
}

nonisolated extension Event {
    var isCancelled: Bool { status == .cancelled }

    /// The event's color.
    var theme: EventTheme { EventTheme(hue: themeHue, grayscale: themeGrayscale) }

    /// The event's accent colors (buttons, the pill, icons, links).
    var accent: AccentColors { AccentColors(theme: theme, accentHue: accentHue) }

    /// The details this app knows how to draw.
    var shownDetails: [EventDetail] { details.filter { $0.type != .unknown } }

    /// The color that matches the cover, or nil when it isn't known.
    var coverTheme: EventTheme? {
        if coverGrayscale { return .grayscale }
        return coverHue.map { .hue($0) }
    }

    var hasCover: Bool { coverImageUrl != nil }

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
