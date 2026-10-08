import Foundation

/// An event as a notification mentions it (the API's `EventSummary`).
/// Open it by `id` for the rest.
nonisolated struct EventSummary: Codable, Hashable, Identifiable {
    var id: Event.ID
    var url: URL
    var title: String
    var startsAt: Date
    var timeZone: String
    var status: EventStatus
    var coverImageUrl: URL?
}

extension EventSummary {
    /// The summary of a whole event.
    init(event: Event) {
        self.init(
            id: event.id, url: event.url, title: event.title, startsAt: event.startsAt,
            timeZone: event.timeZone, status: event.status, coverImageUrl: event.coverImageUrl
        )
    }
}
