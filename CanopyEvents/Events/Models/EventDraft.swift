import Foundation

/// The editable fields of an event, used by the create/edit form and sent
/// to the repository. The API client turns it into an `EventInput` (POST)
/// or an `EventPatch` with only what changed (PATCH); empty strings
/// become null.
nonisolated struct EventDraft: Hashable {
    var title = ""
    var description = ""
    var startsAt: Date
    var endsAt: Date?
    var timeZone: String
    var locationName = ""
    var locationAddress = ""
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

    var theme: EventTheme {
        get { EventTheme(hue: themeHue, grayscale: themeGrayscale) }
        set {
            (themeHue, themeGrayscale) = newValue.apiFields(keepingHue: themeHue)
            if !themeGrayscale { accentHue = nil }
        }
    }

    /// The accent the event will have.
    var accent: AccentColors { AccentColors(theme: theme, accentHue: accentHue) }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (endsAt.map { $0 > startsAt } ?? true)
    }
}

extension EventDraft {
    /// A blank event starting at the next whole hour, tomorrow evening.
    static func blank(timeZone: TimeZone = .current) -> EventDraft {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now) ?? .now
        let start = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        return EventDraft(startsAt: start, timeZone: timeZone.identifier)
    }

    /// The current values of an existing event, ready to edit.
    init(event: Event) {
        self.init(
            title: event.title,
            description: event.description ?? "",
            startsAt: event.startsAt,
            endsAt: event.endsAt,
            timeZone: event.timeZone,
            locationName: event.locationName ?? "",
            locationAddress: event.locationAddress ?? "",
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
