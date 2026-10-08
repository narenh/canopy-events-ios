/// What a list's link is for (`GET /api/v1/list-links/{code}`, the API's
/// `ListLink`; named after `FriendLinkOwner`, since `ListLink` is the
/// glass link view): the list's name, its owner, and, signed in, whether
/// it's yours or you're on it. Opening it joins nobody.
nonisolated struct ListLinkOwner: Codable, Hashable {
    var list: ListName
    var owner: Person
    /// Nil signed out.
    var viewer: ListLinkViewer?
}
