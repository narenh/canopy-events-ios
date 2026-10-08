import Foundation

/// Formats an event's time in the event's own time zone, so a party in
/// New York reads "8 PM" New York time wherever you are; when that isn't
/// your clock, the zone is said too. The web's `whenHead` and `whenRow`.
enum EventDateFormatter {
    /// The big date at the top of the event page: "Saturday, October 10"
    /// (with the year when it isn't this year), or for an event over more
    /// than one day "Fri, Oct 9 – Sun, Oct 11".
    static func headDate(for event: Event) -> String {
        if let end = event.endsAt, spansDays(event, end) {
            return day(event.startsAt, event) + " – " + day(end, event)
        }
        var style = Date.FormatStyle().weekday(.wide).month(.wide).day()
        if !isThisYear(event) { style = style.year() }
        style.timeZone = event.eventTimeZone
        return event.startsAt.formatted(style)
    }

    /// The time under it: "7:30 PM – 11:30 PM", or just "7:30 PM".
    static func headTime(for event: Event) -> String {
        time(event.startsAt, event) + (event.endsAt.map { " – " + time($0, event) } ?? "")
    }

    /// "Times are in Eastern Time." when the event's clock isn't yours.
    static func zoneNote(for event: Event, viewer: TimeZone = .current) -> String? {
        let zone = event.eventTimeZone
        guard !TimeZoneName.sameClock(zone, viewer, at: event.startsAt) else { return nil }
        return "Times are in \(TimeZoneName.friendly(zone, at: event.startsAt))."
    }

    /// "Sat, Oct 31 · 7:30 PM Pacific Time": one moment, with its zone by
    /// name (the wall's "moved it to...").
    static func short(_ date: Date, in zone: TimeZone) -> String {
        var day = Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day()
        day.timeZone = zone
        var time = Date.FormatStyle(date: .omitted, time: .shortened)
        time.timeZone = zone
        return date.formatted(day) + " · " + date.formatted(time) + " " + TimeZoneName.friendly(zone, at: date)
    }

    /// The bold line above a title in a list: "Sat, Oct 10 · 7:30 PM"
    /// (plus " EDT" when it's another clock), or "Fri, Oct 9 – Sun, Oct 11".
    static func rowLine(for event: Event, viewer: TimeZone = .current) -> String {
        if let end = event.endsAt, spansDays(event, end) {
            return day(event.startsAt, event) + " – " + day(end, event)
        }
        let zone = event.eventTimeZone
        let suffix = TimeZoneName.sameClock(zone, viewer, at: event.startsAt)
            ? "" : " " + TimeZoneName.abbreviation(zone, at: event.startsAt)
        return day(event.startsAt, event) + " · " + time(event.startsAt, event) + suffix
    }

    /// "Sat, Oct 11, 7:30 – 11:00 PM": the whole range on one line.
    static func range(for event: Event) -> String {
        range(start: event.startsAt, end: event.endsAt, timeZone: event.eventTimeZone)
    }

    static func range(start: Date, end: Date?, timeZone: TimeZone) -> String {
        if let end {
            var style = Date.IntervalFormatStyle(date: .abbreviated, time: .shortened)
            style.timeZone = timeZone
            return (start..<max(start, end)).formatted(style)
        }
        var style = Date.FormatStyle(date: .abbreviated, time: .shortened)
        style.timeZone = timeZone
        return start.formatted(style)
    }

    // MARK: Pieces

    private static func day(_ date: Date, _ event: Event) -> String {
        var style = Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day()
        if !isThisYear(event) { style = style.year() }
        style.timeZone = event.eventTimeZone
        return date.formatted(style)
    }

    private static func time(_ date: Date, _ event: Event) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = event.eventTimeZone
        return date.formatted(style)
    }

    private static func spansDays(_ event: Event, _ end: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = event.eventTimeZone
        return !calendar.isDate(event.startsAt, inSameDayAs: end)
    }

    private static func isThisYear(_ event: Event) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = event.eventTimeZone
        return calendar.component(.year, from: event.startsAt) == calendar.component(.year, from: .now)
    }
}
