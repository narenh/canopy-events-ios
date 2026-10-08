import Foundation

/// Lists you're on: opening a list's link, joining (which invites you to
/// its events still to come), and leaving. A member never sees who else
/// is on a list, nor how many.
extension MockEventsRepository {
    func listMemberships() async throws -> [ListMembership] {
        await pause()
        return backend.lists
            .compactMap { membership(in: $0) }
            .sorted { $0.joinedAt > $1.joinedAt }
    }

    /// The owner isn't told; invitations already made stay.
    func leaveList(id: ListMembership.ID) async throws {
        await pause()
        guard var list = backend.list(id: id), list.hasMember(personId) else { throw APIError.notAMember }
        list.members.removeAll { $0.person.id == personId }
        backend.save(list)
    }

    /// Joins nobody.
    func listLink(code: String) async throws -> ListLinkOwner {
        await pause()
        guard let list = backend.list(code: code), let owner = backend.person(list.ownerId) else {
            throw APIError.listLinkNotFound
        }
        return ListLinkOwner(
            list: ListName(name: list.name), owner: owner,
            viewer: ListLinkViewer(isOwner: list.ownerId == personId, isMember: list.hasMember(personId))
        )
    }

    /// Quick accounts can join. Your own list is `own_list`; already on
    /// it changes nothing.
    func joinList(code: String) async throws -> ListJoined {
        await pause()
        guard let list = backend.list(code: code) else { throw APIError.listLinkNotFound }
        guard list.ownerId != personId else { throw APIError.ownList }
        if let membership = membership(in: list) { return ListJoined(list: membership, invitedTo: 0) }
        guard list.members.count < 1000 else { throw APIError.listFull }
        let invitedTo = backend.join(currentUser.person, listId: list.id)
        guard let joined = backend.list(id: list.id).flatMap(membership(in:)) else { throw APIError.listNotFound }
        return ListJoined(list: joined, invitedTo: invitedTo)
    }

    /// The list as `currentUser`, a member, sees it; nil if they aren't on it.
    private func membership(in list: MockListRecord) -> ListMembership? {
        guard let member = list.members.first(where: { $0.person.id == personId }),
              let owner = backend.person(list.ownerId) else { return nil }
        return ListMembership(id: list.id, name: list.name, owner: owner, joinedAt: member.joinedAt)
    }
}
