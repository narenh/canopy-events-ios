import Foundation

/// Dates relative to today, so the mock world never goes stale: upcoming
/// events stay upcoming whenever you run the app.
enum MockDate {
    /// `days` from today at `hour:minute` wall-clock time in `timeZone`.
    static func at(days: Int, hour: Int, minute: Int = 0, timeZone: String = "America/Los_Angeles") -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZone) ?? .current
        let day = calendar.date(byAdding: .day, value: days, to: .now) ?? .now
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    /// `minutes` ago, for wall posts and notifications.
    static func ago(minutes: Int) -> Date {
        Date.now.addingTimeInterval(TimeInterval(-minutes * 60))
    }
}
