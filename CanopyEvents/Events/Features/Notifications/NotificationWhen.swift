import Foundation

/// The compact when on an invite notification, on the event's own clock:
/// "10/16 · 7p", "10/16 · 7:30p", "1/2/27 · 12a". The date is M/d (M/d/yy
/// when it isn't this year there); the time is the hour with "a" or "p",
/// and the minutes only when they aren't :00. The server words its pushes
/// the same way (docs/push-payloads.md).
nonisolated enum NotificationWhen {
    static func string(_ date: Date, in timeZone: TimeZone, now: Date = .now) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let (year, month, day) = (parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
        let (hour, minute) = (parts.hour ?? 0, parts.minute ?? 0)
        var line = "\(month)/\(day)"
        if year != calendar.component(.year, from: now) {
            line += "/" + String(format: "%02d", year % 100)
        }
        let twelve = hour % 12 == 0 ? 12 : hour % 12
        let minutes = minute == 0 ? "" : String(format: ":%02d", minute)
        return line + " · \(twelve)\(minutes)\(hour < 12 ? "a" : "p")"
    }

    /// "10/16 · 7p · Throw Eggs at Karl": when, then the event's title.
    static func line(for event: EventSummary, now: Date = .now) -> String {
        let zone = TimeZone(identifier: event.timeZone) ?? .current
        return string(event.startsAt, in: zone, now: now) + " · " + event.title
    }
}
