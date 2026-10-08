/// How someone is in your friends list (the API's `Friend.source`): events
/// you were both at, added by id, a friend link (yours or theirs), or an
/// invitation (either way). A way in wins over events in common.
nonisolated enum FriendSource: String, Codable, Hashable, Sendable {
    case sharedEvents = "shared_events"
    case added
    case link
    case invite
}
