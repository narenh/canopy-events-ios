/// Someone who wasn't added to a list, and why (the API's
/// `ListMembersAdded.skipped[]`).
nonisolated struct SkippedListAdd: Codable, Hashable {
    var personId: Person.ID
    var reason: SkippedListAddReason
}
