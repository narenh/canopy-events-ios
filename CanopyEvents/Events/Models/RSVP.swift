import Foundation

/// Your own place on an event (the API's `Rsvp`).
nonisolated struct RSVP: Codable, Hashable {
    var status: RSVPStatus
    /// Plus-ones you're bringing.
    var guests: Int
    /// Whether a host invited you.
    var invited: Bool
    /// When you last answered; nil while only invited.
    var respondedAt: Date?
}
