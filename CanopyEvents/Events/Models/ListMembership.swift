import Foundation

/// A list you're on, as a member sees it (the API's `ListMembership`):
/// its name and owner, never anyone else on it, nor a count.
nonisolated struct ListMembership: Codable, Hashable, Identifiable {
    /// For leaving it; it grants nothing else.
    var id: String
    var name: String
    var owner: Person
    var joinedAt: Date
}
