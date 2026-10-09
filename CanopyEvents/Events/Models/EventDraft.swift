import Foundation

/// The editable fields of an event, used by the create/edit form and sent
/// to the repository. The API client turns it into an `EventInput` (POST)
/// or an `EventPatch` with only what changed (PATCH); empty strings
/// become null. A changed location sends all five of its fields (the
/// server clears a pin left out of a changed place). A new event (a copy
/// too) has no start until the host picks one.
nonisolated struct EventDraft: Hashable {
    var title = ""
    var description = ""
    /// Nil until picked (a new event starts with none).
    var startsAt: Date?
    var endsAt: Date?
    var timeZone: String
    /// Where: what the Location field saves (`LocationFieldModel.value`).
    var location = EventLocation()
    var guestListVisibility = GuestListVisibility.everyone
    /// Plus-ones each answer may bring, 0 to 10.
    var guestsAllowed = 0
    /// The most people going, plus-ones included, 1 to 10,000; nil for no cap.
    var capacity: Int?
    /// The page's color (see `Event.themeHue`); nil for Canopy green.
    var themeHue: Int?
    var themeGrayscale = false
    /// A grey event's accent hue; nil is white (and always nil unless grey).
    var accentHue: Int?
    /// The extra fields, in order.
    var details: [EventDetailInput] = []
    /// A copy's original, whose cover it starts with (`EventInput.coverFrom`).
    /// Nil once the host takes the cover off or picks another.
    var coverFrom: Event.ID?

    var theme: EventTheme {
        get { EventTheme(hue: themeHue, grayscale: themeGrayscale) }
        set {
            (themeHue, themeGrayscale) = newValue.apiFields(keepingHue: themeHue)
            if !themeGrayscale { accentHue = nil }
        }
    }

    /// The accent the event will have.
    var accent: AccentColors { AccentColors(theme: theme, accentHue: accentHue) }

    /// A title, a start, and any end after the start.
    var isValid: Bool {
        guard let startsAt else { return false }
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (endsAt.map { $0 > startsAt } ?? true)
    }
}

extension EventDraft {
    /// A blank event in your time zone, with no date or times yet (as the
    /// web's): picking its day makes it start at 7 PM.
    static func blank(timeZone: TimeZone = .current) -> EventDraft {
        EventDraft(timeZone: timeZone.identifier)
    }

    /// A copy's starting fields (`duplicateDraft`), with no date or times.
    init(duplicate: DuplicateDraft) {
        self.init(
            title: duplicate.title,
            description: duplicate.description ?? "",
            timeZone: duplicate.timeZone,
            location: EventLocation(
                locationName: duplicate.locationName, locationAddress: duplicate.locationAddress,
                latitude: duplicate.latitude, longitude: duplicate.longitude, applePlaceId: duplicate.applePlaceId
            ),
            guestListVisibility: duplicate.guestListVisibility,
            guestsAllowed: duplicate.guestsAllowed,
            capacity: duplicate.capacity,
            themeHue: duplicate.themeHue,
            themeGrayscale: duplicate.themeGrayscale,
            accentHue: duplicate.accentHue,
            details: duplicate.details,
            coverFrom: duplicate.coverFrom
        )
    }

    /// The current values of an existing event, ready to edit.
    init(event: Event) {
        self.init(
            title: event.title,
            description: event.description ?? "",
            startsAt: event.startsAt,
            endsAt: event.endsAt,
            timeZone: event.timeZone,
            location: event.location,
            guestListVisibility: event.guestListVisibility,
            guestsAllowed: event.guestsAllowed,
            capacity: event.capacity,
            themeHue: event.themeHue,
            themeGrayscale: event.themeGrayscale,
            accentHue: event.accentHue,
            details: event.shownDetails.map(EventDetailInput.init)
        )
    }
}
