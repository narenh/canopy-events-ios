/// The answer to joining a list (the API's `ListJoined`): the membership,
/// and how many events you were invited to just now (the list's attached
/// events still to come).
nonisolated struct ListJoined: Codable, Hashable {
    var list: ListMembership
    var invitedTo: Int
}
