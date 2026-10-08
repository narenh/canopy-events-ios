import Foundation

/// Formats an event's time in the event's own time zone, so a party in
/// New York reads "8 PM EDT" wherever you are. When the event's zone is
/// the same as the device's, the zone is left off.
enum EventDateFormatter {
    /// "Sat, Oct 11, 7:30 – 11:00 PM" (plus " EDT" when it's another zone).
    static func range(for event: Event) -> String {
        range(start: event.startsAt, end: event.endsAt, timeZone: event.eventTimeZone)
    }

    static func range(start: Date, end: Date?, timeZone: TimeZone) -> String {
        let text: String
        if let end {
            var style = Date.IntervalFormatStyle(date: .abbreviated, time: .shortened)
            style.timeZone = timeZone
            text = (start..<max(start, end)).formatted(style)
        } else {
            var style = Date.FormatStyle(date: .abbreviated, time: .shortened)
            style.timeZone = timeZone
            text = start.formatted(style)
        }
        return text + zoneSuffix(for: timeZone, at: start)
    }

    /// "Sat, Oct 11": just the day, for compact rows.
    static func day(for event: Event) -> String {
        var style = Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day()
        style.timeZone = event.eventTimeZone
        return event.startsAt.formatted(style)
    }

    /// "7:30 PM": just the start time, for compact rows.
    static func startTime(for event: Event) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = event.eventTimeZone
        return event.startsAt.formatted(style) + zoneSuffix(for: event.eventTimeZone, at: event.startsAt)
    }

    private static func zoneSuffix(for timeZone: TimeZone, at date: Date) -> String {
        guard timeZone.identifier != TimeZone.current.identifier else { return "" }
        return " " + (timeZone.abbreviation(for: date) ?? timeZone.identifier)
    }
}
