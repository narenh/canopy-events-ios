/// The answer to adding people to one of your lists (the API's
/// `ListMembersAdded`): each id ends up in `added`, `alreadyOn` or
/// `skipped`; `invitedTo` is how many of the list's events still to come
/// at least one of them was invited to; `list` has the new count.
nonisolated struct ListMembersAdded: Codable, Hashable {
    var added: [Person]
    /// Ids of people who were on it already: nothing about them changed.
    var alreadyOn: [Person.ID]
    var skipped: [SkippedListAdd]
    var invitedTo: Int
    var list: OwnedList
}
