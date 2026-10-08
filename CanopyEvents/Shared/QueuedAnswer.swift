import Foundation

/// An answer given on an expanded notification, waiting for the app to
/// send it: which event, which button (`GOING` / `NOT_GOING`), and the
/// inbox entry to mark read.
nonisolated struct QueuedAnswer: Codable, Hashable, Sendable {
    var eventId: String
    var action: String
    var notificationId: String?
    var answeredAt: Date
}
