/// You and a list link: your own list (joining it is a 409), or one
/// you're on already.
nonisolated struct ListLinkViewer: Codable, Hashable {
    var isOwner: Bool
    var isMember: Bool
}
