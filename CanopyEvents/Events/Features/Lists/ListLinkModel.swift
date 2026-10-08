import Foundation
import Observation

/// Someone's list link, `/l/<code>`: whose list it is, and joining it.
/// Opening it joins nobody.
@Observable
final class ListLinkModel {
    let code: String
    private(set) var link: ListLinkOwner?
    /// After saying yes: the membership and how many events it invited you to.
    private(set) var joined: ListJoined?
    private(set) var isNotFound = false
    private(set) var isJoining = false
    var errorMessage: String?

    init(code: String) {
        self.code = code
    }

    /// The owner's first name, as the web says it ("Join Ana's Drag Race?").
    var ownerFirst: String {
        guard let owner = link?.owner else { return "" }
        return owner.firstName.isEmpty ? owner.fullName : owner.firstName
    }

    func load(from repository: any EventsRepository) async {
        do {
            link = try await repository.listLink(code: code)
        } catch let error as APIError where error.reason == .listLinkNotFound {
            isNotFound = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func join(using repository: any EventsRepository) async {
        isJoining = true
        defer { isJoining = false }
        do {
            joined = try await repository.joinList(code: code)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
