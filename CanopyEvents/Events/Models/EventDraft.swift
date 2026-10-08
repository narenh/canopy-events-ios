import Foundation

/// The editable fields of an event, used by the create/edit form and sent
/// to the repository. Mirrors the API's `EventInput` (plus the planned
/// capacity and plus-ones fields).
nonisolated struct EventDraft: Hashable {
    var title = ""
    var description = ""
    var startsAt: Date
    var endsAt: Date?
    var timeZone: String
    var locationName = ""
    var locationAddress = ""
    var guestListVisibility = GuestListVisibility.everyone
    var capacity: Int?
    var plusOnesAllowed = 0

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
            capacity: event.capacity,
            plusOnesAllowed: event.plusOnesAllowed
        )
    }
}
