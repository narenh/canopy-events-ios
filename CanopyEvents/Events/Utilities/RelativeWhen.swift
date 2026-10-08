import Foundation

/// What people scan for: "Tonight", "Tomorrow", "This Saturday", "Next
/// Tuesday", "In 3 weeks", "Happening now", "Ended". Days are counted on
/// the event's own clock; weeks are calendar weeks starting Monday. Nil
/// for a cancelled event (it says so instead). The web's `relativeWhen`.
nonisolated enum RelativeWhen {
    static func string(for event: Event, now: Date = .now) -> String? {
        switch EventPhase(event: event, now: now) {
        case .cancelled: return nil
        case .now: return "Happening now"
        case .over: return "Ended"
        case .upcoming: break
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = event.eventTimeZone
        let startDay = dayNumber(event.startsAt, calendar)
        let today = dayNumber(now, calendar)
        let days = startDay - today
        // Day 0 (1 Jan 1970) was a Thursday: +3 makes weeks start Monday.
        let weeks = floorDiv(startDay + 3, 7) - floorDiv(today + 3, 7)
        var weekdayStyle = Date.FormatStyle().weekday(.wide)
        weekdayStyle.timeZone = event.eventTimeZone
        let weekday = event.startsAt.formatted(weekdayStyle)
        if days <= 0 { return calendar.component(.hour, from: event.startsAt) >= 17 ? "Tonight" : "Today" }
        if days == 1 { return "Tomorrow" }
        if weeks == 0 { return "This \(weekday)" }
        if weeks == 1 { return "Next \(weekday)" }
        if days < 28 { return "In \(max(2, Int((Double(days) / 7).rounded()))) weeks" }
        let months = Int((Double(days) / 30.4).rounded())
        return months <= 1 ? "In a month" : "In \(months) months"
    }

    /// Days since 1 Jan 1970 of the date's calendar day, on that clock.
    private static func dayNumber(_ date: Date, _ calendar: Calendar) -> Int {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let midnight = utc.date(from: parts) ?? date
        return Int((midnight.timeIntervalSince1970 / 86_400).rounded())
    }

    private static func floorDiv(_ a: Int, _ b: Int) -> Int {
        Int((Double(a) / Double(b)).rounded(.down))
    }
}
