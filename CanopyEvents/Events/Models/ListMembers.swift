/// A page of who's on one of your lists, newest first (the API's
/// `ListMembers`).
nonisolated struct ListMembers: Codable, Hashable {
    var members: [ListMember]
    /// Pass back for the next page; nil at the end.
    var nextCursor: String?
}
