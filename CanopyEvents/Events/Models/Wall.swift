/// A page of an event's activity wall, newest first (the API's `Wall`).
/// Readable by whoever can see the guest list's names; anyone else gets
/// `wallVisible` false and no entries.
nonisolated struct Wall: Codable, Hashable {
    var wallVisible: Bool
    var entries: [WallEntry]
    /// Whether you may post: hosts, and answers of going, maybe or waitlisted.
    var canPost: Bool
    /// Pass back for the next page; nil at the end.
    var nextCursor: String?
}
