import Foundation
import Testing
@testable import CanopyEvents

/// The 7 PM default (canopy-events' docs/decision-log.md, "Date and time
/// picker"): `ClockTime.startTime` is the web's `UI.startTimeFor`, and the
/// editor uses it when a day is picked.
@MainActor
struct StartTimeTests {
    private let seven = ClockTime.defaultStart
    private let morning = ClockTime(hour: 9, minute: 30)

    /// Noon on a day, on a zone's clock.
    private func noon(_ year: Int, _ month: Int, _ day: Int, in zone: String) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func utc(_ text: String) -> Date {
        try! Date(text, strategy: .iso8601)
    }

    @Test func aNewEventsDayWithNoTimeIsSevenPM() {
        #expect(seven == ClockTime(hour: 19, minute: 0))
        #expect(ClockTime.startTime(isNew: true, dayPicked: true, chosen: nil) == seven)
        // A chosen time stays; no day, nothing to fill; an edited event keeps its own.
        #expect(ClockTime.startTime(isNew: true, dayPicked: true, chosen: morning) == morning)
        #expect(ClockTime.startTime(isNew: true, dayPicked: false, chosen: nil) == nil)
        #expect(ClockTime.startTime(isNew: false, dayPicked: true, chosen: nil) == nil)
        #expect(ClockTime.startTime(isNew: false, dayPicked: true, chosen: morning) == morning)
    }

    @Test func aTimeIsPutOnADayOnTheEventsClock() {
        let la = TimeZone(identifier: "America/Los_Angeles")!
        #expect(seven.on(noon(2026, 10, 16, in: "America/Los_Angeles"), in: la) == utc("2026-10-17T02:00:00Z"))
        // The day after the clocks go back: 7 PM is PST.
        #expect(seven.on(noon(2026, 11, 1, in: "America/Los_Angeles"), in: la) == utc("2026-11-02T03:00:00Z"))
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        #expect(seven.on(noon(2026, 10, 16, in: "Asia/Tokyo"), in: tokyo) == utc("2026-10-16T10:00:00Z"))
        #expect(ClockTime(of: utc("2026-10-16T10:00:00Z"), in: tokyo) == seven)
    }

    @Test func pickingANewEventsDayStartsItAtSevenInItsZone() {
        let model = EventEditorModel(event: nil)
        model.draft.timeZone = "Asia/Tokyo"
        #expect(model.draft.startsAt == nil && model.startTime == nil)
        model.pickStartDay(noon(2026, 10, 16, in: "Asia/Tokyo"))
        #expect(model.draft.startsAt == utc("2026-10-16T10:00:00Z") && model.draft.endsAt == nil)
        // Another day keeps the time, 7 PM or a chosen one.
        model.pickStartDay(noon(2026, 10, 20, in: "Asia/Tokyo"))
        #expect(model.draft.startsAt == utc("2026-10-20T10:00:00Z"))
        model.pickStartTime(ClockTime(hour: 20, minute: 15))
        model.pickStartDay(noon(2026, 10, 22, in: "Asia/Tokyo"))
        #expect(model.draft.startsAt == utc("2026-10-22T11:15:00Z"))
    }

    @Test func aTimePickedFirstIsNeverOverwritten() {
        let model = EventEditorModel(event: nil)
        model.draft.timeZone = "America/New_York"
        model.pickStartTime(morning)
        #expect(model.draft.startsAt == nil && model.startTime == morning && !model.draft.isValid)
        model.pickStartDay(noon(2026, 10, 16, in: "America/New_York"))
        #expect(model.draft.startsAt == utc("2026-10-16T13:30:00Z"))
    }

    @Test func aCopyGetsSevenPMInTheOriginalsZone() {
        var draft = PreviewData.duplicateDraft(MockEvents.dragFinaleId)
        draft.timeZone = "America/New_York"
        let model = EventEditorModel(duplicating: draft)
        model.pickStartDay(noon(2026, 10, 16, in: "America/New_York"))
        #expect(model.draft.startsAt == utc("2026-10-16T23:00:00Z"))
    }

    @Test func anExistingEventsDateMovesWithoutItsTime() throws {
        let event = PreviewData.event(MockEvents.gameNightId)
        let model = EventEditorModel(event: event)
        model.addEnd()
        let length = try #require(model.draft.endsAt).timeIntervalSince(event.startsAt)
        let day = event.startsAt.addingTimeInterval(3 * 86_400)
        model.pickStartDay(day)
        let start = try #require(model.draft.startsAt)
        #expect(ClockTime(of: start, in: event.eventTimeZone) == ClockTime(of: event.startsAt, in: event.eventTimeZone))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = event.eventTimeZone
        #expect(calendar.isDate(start, inSameDayAs: day) && model.draft.endsAt == start.addingTimeInterval(length))
    }
}
