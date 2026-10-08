import Foundation

/// "5 min. ago", "yesterday", "in 3 days": for wall posts and the inbox.
enum RelativeTime {
    static func string(for date: Date) -> String {
        date.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
    }
}
