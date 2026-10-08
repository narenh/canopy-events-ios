/// You and a friend link: your own, or someone in your list already.
nonisolated struct FriendLinkViewer: Codable, Hashable {
    var isYou: Bool
    var isFriend: Bool
}
