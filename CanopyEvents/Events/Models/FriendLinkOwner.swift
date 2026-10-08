/// Whose friend link a code is (`GET /api/v1/friend-links/{code}`):
/// the owner, and, signed in, whether it's you and whether they're in
/// your list already. Opening it adds nobody.
nonisolated struct FriendLinkOwner: Codable, Hashable {
    var person: Person
    var viewer: FriendLinkViewer?
}
