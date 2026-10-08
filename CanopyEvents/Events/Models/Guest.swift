import Foundation

/// One row of an event's guest list (the API's `Guest`).
nonisolated struct Guest: Codable, Hashable, Identifiable {
    var person: Person
    var status: RSVPStatus
    /// Plus-ones they're bringing.
    var guests: Int
    /// More plus-ones than the event now allows (the host lowered
    /// `guestsAllowed` after they answered).
    var guestsOverLimit: Bool
    var respondedAt: Date?

    var id: Person.ID { person.id }
}
