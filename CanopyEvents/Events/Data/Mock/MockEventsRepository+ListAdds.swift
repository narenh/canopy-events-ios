import Foundation

/// The owner adding people to a list of theirs (docs/api.md, "Adding
/// people"): the same people they could invite, friends or not. Being
/// added is the same as joining by the link.
extension MockEventsRepository {
    /// The most people a list can have; an add that wouldn't all fit adds nobody.
    static let listCapacity = 1000

    /// Verified owners only (403 `email_unverified`, then 404
    /// `list_not_found` for anyone else's list or none), 1 to 100 ids.
    /// You, and anyone unknown or opted out of your invitations, are
    /// skipped (`is_you`, `not_found`); someone on it already is
    /// `alreadyOn`, unchanged. Everyone added is invited to the list's
    /// events still to come, in the same step. All or nothing at 1,000
    /// people (409 `list_full`). (The server's 300 a day isn't mocked.)
    func addListMembers(listId: OwnedList.ID, personIds: [Person.ID]) async throws -> ListMembersAdded {
        await pause()
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        let list = try ownList(listId)
        guard (1...100).contains(personIds.count) else { throw APIError.badListPersonIds }

        var adding: [Person] = []
        var alreadyOn: [Person.ID] = []
        var skipped: [SkippedListAdd] = []
        var seen = Set<Person.ID>()
        for id in personIds where seen.insert(id).inserted {
            if id == personId {
                skipped.append(SkippedListAdd(personId: id, reason: .isYou))
            } else if list.hasMember(id) {
                alreadyOn.append(id)
            } else if let person = knownPerson(id), !backend.inviteOptouts[id, default: []].contains(personId) {
                adding.append(person)
            } else {
                skipped.append(SkippedListAdd(personId: id, reason: .notFound))
            }
        }
        guard list.members.count + adding.count <= Self.listCapacity else { throw APIError.listFull }
        let invitedTo = backend.putOn(adding, listId: listId, source: .added)
        return ListMembersAdded(added: adding, alreadyOn: alreadyOn, skipped: skipped,
                                invitedTo: invitedTo, list: try ownList(listId).owned)
    }
}
