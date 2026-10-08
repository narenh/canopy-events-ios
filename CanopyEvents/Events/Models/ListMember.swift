import Foundation

/// Someone on one of your lists, and when they joined (an item of the
/// API's `ListMembers.members`). Only the owner ever gets these.
nonisolated struct ListMember: Codable, Hashable, Identifiable {
    var person: Person
    var joinedAt: Date

    var id: Person.ID { person.id }
}
