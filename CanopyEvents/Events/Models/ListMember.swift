import Foundation

/// Someone on one of your lists, when they joined or were added, and
/// which (an item of the API's `ListMembers.members`). Only the owner
/// ever gets these.
nonisolated struct ListMember: Codable, Hashable, Identifiable {
    var person: Person
    /// When they joined, or were added.
    var joinedAt: Date
    var source: ListMemberSource

    var id: Person.ID { person.id }
}
