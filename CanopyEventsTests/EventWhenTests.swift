import Foundation
import Testing
@testable import CanopyEvents

/// How soon, the big when, list lines, friendly zones and the nearby
/// zone list, as the web words them.
struct EventWhenTests {
    private let pacific = TimeZone(identifier: "America/Los_Angeles")!

    /// Wednesday 7 October 2026, noon Pacific.
    private var now: Date { date(2026, 10, 7, 12) }

    private func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int, _ minute: Int = 0, zone: String = "America/Los_Angeles") -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        return calendar.date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: minute))!
    }

    private func event(starts: Date, hours: Double? = 3, zone: String = "America/Los_Angeles", cancelled: Bool = false) -> Event {
        var event = PreviewData.event()
        event.startsAt = starts
        event.endsAt = hours.map { starts.addingTimeInterval($0 * 3600) }
        event.timeZone = zone
        event.status = cancelled ? .cancelled : .active
        return event
    }

    @Test(arguments: [
        ((2026, 10, 7, 19), "Tonight"), ((2026, 10, 7, 14), "Today"), ((2026, 10, 8, 19), "Tomorrow"),
        ((2026, 10, 10, 19), "This Saturday"), ((2026, 10, 12, 19), "Next Monday"), ((2026, 10, 18, 19), "Next Sunday"),
        ((2026, 10, 21, 19), "In 2 weeks"), ((2026, 10, 30, 19), "In 3 weeks"), ((2026, 11, 7, 19), "In a month"),
        ((2027, 1, 7, 19), "In 3 months"),
    ])
    func howSoon(start: (Int, Int, Int, Int), words: String) {
        let e = event(starts: date(start.0, start.1, start.2, start.3))
        #expect(RelativeWhen.string(for: e, now: now) == words)
    }

    @Test func nowEndedAndCancelled() {
        #expect(RelativeWhen.string(for: event(starts: date(2026, 10, 7, 11)), now: now) == "Happening now")
        #expect(RelativeWhen.string(for: event(starts: date(2026, 10, 6, 11)), now: now) == "Ended")
        #expect(RelativeWhen.string(for: event(starts: date(2026, 10, 9, 11), cancelled: true), now: now) == nil)
    }

    @Test func zoneNamesAreFriendly() {
        let names = ["America/Los_Angeles", "Pacific/Honolulu", "America/Phoenix", "America/Mexico_City", "Europe/London",
                     "Europe/Paris", "Asia/Kolkata"].map { TimeZoneName.friendly(TimeZone(identifier: $0)!, at: now) }
        #expect(names == ["Pacific Time", "Hawaii Time", "Arizona", "Mexico City", "London", "Central European Time", "India Time"])
        #expect(TimeZoneName.friendly(TimeZone(identifier: "America/Vancouver")!, at: now) == "Pacific Time")
    }

    @Test func nearbyFromPacificIsTheSix() {
        let names = TimeZoneChoices.nearby(viewer: pacific, at: now, selected: pacific).map(\.name)
        #expect(names == ["Hawaii Time", "Alaska Time", "Pacific Time", "Mountain Time", "Central Time", "Eastern Time"])
        let marked = TimeZoneChoices.nearby(viewer: pacific, at: now, selected: TimeZone(identifier: "Asia/Tokyo")!)
        #expect(marked.last?.name == "Japan Time" && marked.last?.isSelected == true)
        #expect(marked.first { $0.isYours }?.name == "Pacific Time")
    }

    @Test func theBigWhenAndTheListLine() {
        let e = event(starts: date(2026, 10, 10, 19, 30), hours: 4)
        #expect(EventDateFormatter.headDate(for: e).hasPrefix("Saturday, October 10"))
        #expect(EventDateFormatter.headTime(for: e).replacingOccurrences(of: "\u{202F}", with: " ") == "7:30 PM – 11:30 PM")
        #expect(EventDateFormatter.zoneNote(for: e, viewer: pacific) == nil)
        let line = EventDateFormatter.rowLine(for: e, viewer: pacific).replacingOccurrences(of: "\u{202F}", with: " ")
        #expect(line == "Sat, Oct 10 · 7:30 PM")
        let ny = event(starts: date(2026, 10, 10, 19, zone: "America/New_York"), zone: "America/New_York")
        #expect(EventDateFormatter.zoneNote(for: ny, viewer: pacific) == "Times are in Eastern Time.")
        #expect(EventDateFormatter.rowLine(for: ny, viewer: pacific).hasSuffix("EDT"))
    }
}
