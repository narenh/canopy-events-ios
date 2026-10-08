import Foundation

/// Your own lists: making, renaming, deleting, a new link, and who's on
/// them. Someone else's list is always `list_not_found`, the same as none.
extension MockEventsRepository {
    func lists() async throws -> [OwnedList] {
        await pause()
        return backend.lists.filter { $0.ownerId == personId }.map(\.owned)
    }

    func createList(name: String) async throws -> OwnedList {
        await pause()
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        let name = try Self.listName(name)
        guard backend.lists.count(where: { $0.ownerId == personId }) < 50 else { throw APIError.tooManyLists }
        let list = MockListRecord(id: MockBackend.newCode(), ownerId: personId, name: name,
                                  code: MockBackend.newCode(), createdAt: .now, members: [])
        backend.lists.append(list)
        return list.owned
    }

    func renameList(id: OwnedList.ID, name: String) async throws -> OwnedList {
        await pause()
        var list = try ownList(id)
        list.name = try Self.listName(name)
        backend.save(list)
        return list.owned
    }

    /// Gone, with its members and its place on events; invitations stay.
    func deleteList(id: OwnedList.ID) async throws {
        await pause()
        _ = try ownList(id)
        backend.lists.removeAll { $0.id == id }
        for index in records.indices {
            records[index].attachedLists.removeAll { $0.listId == id }
        }
    }

    func resetListLink(id: OwnedList.ID) async throws -> OwnedList {
        await pause()
        var list = try ownList(id)
        list.code = MockBackend.newCode()
        backend.save(list)
        return list.owned
    }

    /// Newest first. The owner only: a member gets `list_not_found`.
    func listMembers(listId: OwnedList.ID, page: PageRequest) async throws -> ListMembers {
        await pause()
        let list = try ownList(listId)
        let newest = list.members.sorted { $0.joinedAt > $1.joinedAt }
        let (members, next) = try MockPaging.page(newest, page)
        return ListMembers(members: members, nextCursor: next)
    }

    /// They aren't told.
    func removeListMember(listId: OwnedList.ID, personId memberId: Person.ID) async throws {
        await pause()
        var list = try ownList(listId)
        guard list.hasMember(memberId) else { throw APIError.notAMember }
        list.members.removeAll { $0.person.id == memberId }
        backend.save(list)
    }

    // MARK: Helpers

    /// One of yours, or `list_not_found`.
    func ownList(_ id: OwnedList.ID) throws -> MockListRecord {
        guard let list = backend.list(id: id), list.ownerId == personId else { throw APIError.listNotFound }
        return list
    }

    /// The server's tidying: runs of spaces made one, trimmed, 1 to 60
    /// characters, no control characters.
    static func listName(_ typed: String) throws -> String {
        let name = typed.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        guard (1...60).contains(name.count), !name.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
            throw APIError.badListName
        }
        return name
    }
}
