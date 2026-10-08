import Foundation

/// What the mock "server" stores for one list: its owner, name, link code
/// and who joined. `MockRules` turns it into what each person may see
/// (`OwnedList` for the owner, `ListMembership` for a member).
struct MockListRecord {
    var id: String
    var ownerId: Person.ID
    var name: String
    var code: String
    var createdAt: Date
    /// Who joined, oldest first.
    var members: [ListMember]

    var url: String { "https://events.canopysf.com/l/\(code)" }

    func hasMember(_ personId: Person.ID) -> Bool {
        members.contains { $0.person.id == personId }
    }

    /// The list as its owner sees it.
    var owned: OwnedList {
        OwnedList(id: id, name: name, code: code, url: url, memberCount: members.count, createdAt: createdAt)
    }
}
