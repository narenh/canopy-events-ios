import Foundation

/// The friends rules (docs/api.md, "Friends and invitations"): a list is
/// one way, made of events in common plus people added, linked or
/// invited, minus those taken out.
extension MockBackend {
    /// Someone's whole list: the way in wins over events in common; most
    /// events in common first, then the rest by name.
    func friends(of me: Person) -> [Friend] {
        var list: [Person.ID: Friend] = [:]
        for friend in MockRules.friends(of: me, in: records) { list[friend.id] = friend }
        for (id, source) in friendEdges[me.id, default: [:]] {
            guard let person = person(id) else { continue }
            var friend = list[id] ?? Friend(person: person, source: source, eventsInCommon: 0, lastTogetherAt: nil)
            friend.source = source
            list[id] = friend
        }
        let removed = removedFriends[me.id, default: []]
        return list.values
            .filter { !removed.contains($0.id) && $0.id != me.id }
            .sorted {
                ($0.eventsInCommon, $1.person.fullName) > ($1.eventsInCommon, $0.person.fullName)
            }
    }

    /// Puts `friendId` in `personId`'s list (and takes back a removal).
    func befriend(_ personId: Person.ID, _ friendId: Person.ID, source: FriendSource) {
        guard personId != friendId else { return }
        removedFriends[personId]?.remove(friendId)
        if friendEdges[personId]?[friendId] == nil {
            friendEdges[personId, default: [:]][friendId] = source
        }
    }

    /// Anyone the mock world knows: the sample people and every account.
    func person(_ id: Person.ID) -> Person? {
        MockPeople.everyone.first { $0.id == id } ?? account(id: id)?.person
    }

    /// Someone's friend link code, made the first time.
    func friendLinkCode(for personId: Person.ID) -> String {
        if let code = friendLinks[personId] { return code }
        let code = Self.newCode()
        friendLinks[personId] = code
        return code
    }

    static func newCode() -> String {
        String((0..<12).map { _ in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".randomElement()! })
    }
}
