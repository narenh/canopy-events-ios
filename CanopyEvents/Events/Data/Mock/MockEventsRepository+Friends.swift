import Foundation

/// Friends: the list, adding and taking out, and friend links.
extension MockEventsRepository {
    func friends(page: PageRequest) async throws -> FriendList {
        await pause()
        let (friends, next) = try MockPaging.page(backend.friends(of: currentUser.person), page)
        return FriendList(friends: friends, nextCursor: next)
    }

    func addFriend(personId friendId: Person.ID) async throws -> Friend {
        await pause()
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        guard friendId != personId else { throw APIError.isYou }
        guard backend.person(friendId) != nil else { throw APIError.personNotFound }
        backend.befriend(personId, friendId, source: .added)
        return try friend(friendId)
    }

    func removeFriend(personId friendId: Person.ID) async throws {
        await pause()
        guard backend.friends(of: currentUser.person).contains(where: { $0.id == friendId }) else {
            throw APIError(message: "They aren't in your friends.", reason: .notAFriend)
        }
        backend.friendEdges[personId]?[friendId] = nil
        backend.removedFriends[personId, default: []].insert(friendId)
    }

    func friendLink() async throws -> FriendLink {
        await pause()
        return link(backend.friendLinkCode(for: personId))
    }

    func resetFriendLink() async throws -> FriendLink {
        await pause()
        let code = MockBackend.newCode()
        backend.friendLinks[personId] = code
        return link(code)
    }

    func friendLinkOwner(code: String) async throws -> FriendLinkOwner {
        await pause()
        let ownerId = try owner(of: code)
        guard let person = backend.person(ownerId) else { throw Self.linkNotFound }
        let isFriend = backend.friends(of: currentUser.person).contains { $0.id == ownerId }
        return FriendLinkOwner(person: person, viewer: FriendLinkViewer(isYou: ownerId == personId, isFriend: isFriend))
    }

    /// Both ways: sharing the link is the owner's yes.
    func acceptFriendLink(code: String) async throws -> Friend {
        await pause()
        let ownerId = try owner(of: code)
        guard ownerId != personId else {
            throw APIError(message: "That's your own friend link.", reason: .ownLink)
        }
        backend.befriend(personId, ownerId, source: .link)
        backend.befriend(ownerId, personId, source: .link)
        return try friend(ownerId)
    }

    private func friend(_ id: Person.ID) throws -> Friend {
        guard let friend = backend.friends(of: currentUser.person).first(where: { $0.id == id }) else {
            throw APIError.personNotFound
        }
        return friend
    }

    private func owner(of code: String) throws -> Person.ID {
        guard let owner = backend.friendLinks.first(where: { $0.value == code })?.key else { throw Self.linkNotFound }
        return owner
    }

    private func link(_ code: String) -> FriendLink {
        FriendLink(url: "https://events.canopysf.com/f/\(code)", code: code)
    }

    private static let linkNotFound = APIError(message: "That friend link doesn't work.", reason: .friendLinkNotFound)
}
