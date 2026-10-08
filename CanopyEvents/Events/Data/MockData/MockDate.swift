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

    /// Days from today to the coming `month`/`day` (this year's, or next
    /// year's once it's gone), in Pacific time.
    static func daysUntil(month: Int, day: Int) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        let today = calendar.startOfDay(for: .now)
        let year = calendar.component(.year, from: today)
        for candidate in [year, year + 1] {
            if let date = calendar.date(from: DateComponents(year: candidate, month: month, day: day)), date >= today {
                return calendar.dateComponents([.day], from: today, to: date).day ?? 0
            }
        }
        return 0
    }

    /// `minutes` ago, for wall posts and notifications.
    static func ago(minutes: Int) -> Date {
        Date.now.addingTimeInterval(TimeInterval(-minutes * 60))
    }
}
