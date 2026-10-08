/// A page of your friends, most events in common first (the API's
/// `FriendList`). A page can be short of the limit with more to come.
nonisolated struct FriendList: Codable, Hashable {
    var friends: [Friend]
    /// Pass back for the next page; nil at the end.
    var nextCursor: String?
}
