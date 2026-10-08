import Foundation
import Observation

/// Profile's lists: yours (with making a new one) and the ones you're on
/// (with leaving).
@Observable
final class YourListsModel {
    private(set) var lists: [OwnedList] = []
    private(set) var memberships: [ListMembership] = []
    private(set) var hasLoaded = false
    private(set) var isWorking = false
    /// The new list's name, as typed.
    var newName = ""
    var errorMessage: String?

    var canCreate: Bool {
        !newName.trimmingCharacters(in: .whitespaces).isEmpty && !isWorking
    }

    func load(from repository: any EventsRepository) async {
        do {
            async let lists = repository.lists()
            async let memberships = repository.listMemberships()
            self.lists = try await lists
            self.memberships = try await memberships
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Makes a list from `newName`. Returns it, to open.
    func create(using repository: any EventsRepository) async -> OwnedList? {
        isWorking = true
        defer { isWorking = false }
        do {
            let list = try await repository.createList(name: newName)
            lists.append(list)
            newName = ""
            return list
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func leave(_ membership: ListMembership, using repository: any EventsRepository) async {
        do {
            try await repository.leaveList(id: membership.id)
            memberships.removeAll { $0.id == membership.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
