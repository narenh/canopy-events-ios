import Foundation
import Observation

/// One of your lists and who's on it, for its sheet: rename, a new link,
/// delete, searching its people and taking them off. (Adding them is the
/// sheet's "Add people" step, a `PeoplePickerModel`.)
@Observable
final class OwnListModel {
    let listId: OwnedList.ID
    private(set) var list: OwnedList?
    /// Newest first: all of them (up to the 1,000 a list can have), so
    /// search covers everyone.
    private(set) var members: [ListMember] = []
    /// The name search over its people.
    var query = ""
    /// A line after something was done ("Added 5 people.", "Link copied.").
    var notice: String?
    private(set) var hasLoaded = false
    /// Set when the list is gone (deleted here or elsewhere), so the screen closes.
    private(set) var isGone = false
    var errorMessage: String?

    init(listId: OwnedList.ID) {
        self.listId = listId
    }

    /// Its people whose names match what's typed (everyone when nothing is).
    var shownMembers: [ListMember] {
        members.filter { NameSearch.matches($0.person, query) }
    }

    var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func load(from repository: any EventsRepository) async {
        do {
            guard let list = try await repository.lists().first(where: { $0.id == listId }) else {
                isGone = true
                return
            }
            self.list = list
            members = try await repository.allListMembers(listId: listId)
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rename(to name: String, using repository: any EventsRepository) async {
        await run { self.list = try await repository.renameList(id: self.listId, name: name) }
    }

    func resetLink(using repository: any EventsRepository) async {
        await run { self.list = try await repository.resetListLink(id: self.listId) }
    }

    func delete(using repository: any EventsRepository) async {
        await run {
            try await repository.deleteList(id: self.listId)
            self.isGone = true
        }
    }

    func remove(_ member: ListMember, using repository: any EventsRepository) async {
        await run {
            try await repository.removeListMember(listId: self.listId, personId: member.id)
            self.members.removeAll { $0.id == member.id }
            self.list?.memberCount -= 1
        }
    }

    private func run(_ change: () async throws -> Void) async {
        do {
            try await change()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
