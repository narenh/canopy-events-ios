import Foundation

/// "Joined Oct 8" (by the link) or "Added Oct 8" (by you), with the year
/// only when it isn't this one (the web's `joinedOn`).
enum JoinedDate {
    static func string(for date: Date, source: ListMemberSource = .link, now: Date = .now) -> String {
        let sameYear = Calendar.current.isDate(date, equalTo: now, toGranularity: .year)
        let day = sameYear
            ? date.formatted(.dateTime.month(.abbreviated).day())
            : date.formatted(.dateTime.month(.abbreviated).day().year())
        return source == .added ? "Added \(day)" : "Joined \(day)"
    }
}
