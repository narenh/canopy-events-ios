import Foundation

/// A time of day on an event's clock (its time zone), such as 7:00 PM,
/// with no day: a start time picked before its date.
nonisolated struct ClockTime: Hashable, Sendable {
    /// 0 to 23.
    var hour: Int
    var minute: Int

    /// 7:00 PM: a new event's start once its day is picked.
    static let defaultStart = ClockTime(hour: 19, minute: 0)

    /// The time of day `date` is on `zone`'s clock.
    init(of date: Date, in zone: TimeZone) {
        let parts = Self.calendar(zone).dateComponents([.hour, .minute], from: date)
        self.init(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
    }

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    /// This time on `day`'s date, both on `zone`'s clock.
    func on(_ day: Date, in zone: TimeZone) -> Date? {
        let calendar = Self.calendar(zone)
        var parts = calendar.dateComponents([.year, .month, .day], from: day)
        parts.hour = hour
        parts.minute = minute
        return calendar.date(from: parts)
    }

    /// The start time once a day is picked (the web's `UI.startTimeFor`):
    /// the time already chosen; for a new event with none yet, 7:00 PM. An
    /// event being edited always keeps its own time.
    static func startTime(isNew: Bool, dayPicked: Bool, chosen: ClockTime?) -> ClockTime? {
        isNew && dayPicked && chosen == nil ? defaultStart : chosen
    }

    private static func calendar(_ zone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        return calendar
    }
}
