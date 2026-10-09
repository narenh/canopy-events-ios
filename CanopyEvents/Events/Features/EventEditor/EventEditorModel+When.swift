import Foundation

/// The date and times, on the event's clock. A new event (a copy too)
/// starts with none; picking its day while the start time is still unset
/// makes it 7:00 PM (`ClockTime.startTime`). A time someone chose stays,
/// and an existing event's date moves without its time.
extension EventEditorModel {
    var zone: TimeZone { TimeZone(identifier: draft.timeZone) ?? .current }

    /// The start's time of day: the start's, or one picked before its day.
    var startTime: ClockTime? {
        draft.startsAt.map { ClockTime(of: $0, in: zone) } ?? pendingStartTime
    }

    /// A day picked for the start (any moment of it on the event's clock).
    func pickStartDay(_ day: Date) {
        guard let time = ClockTime.startTime(isNew: isNew, dayPicked: true, chosen: startTime),
              let start = time.on(day, in: zone) else { return }
        setStart(start)
    }

    /// A start time picked: on the start's day, or kept until there is one.
    func pickStartTime(_ time: ClockTime) {
        guard let day = draft.startsAt, let start = time.on(day, in: zone) else {
            pendingStartTime = time
            return
        }
        setStart(start)
    }

    /// Moving the start moves the end with it, keeping the length.
    func setStart(_ start: Date) {
        if let end = draft.endsAt, let old = draft.startsAt {
            draft.endsAt = start.addingTimeInterval(end.timeIntervalSince(old))
        }
        draft.startsAt = start
        pendingStartTime = nil
    }

    /// "+ End time": three hours after the start (offered once there is one).
    func addEnd() {
        guard let start = draft.startsAt else { return }
        draft.endsAt = start.addingTimeInterval(3 * 60 * 60)
    }

    func removeEnd() {
        draft.endsAt = nil
    }
}
