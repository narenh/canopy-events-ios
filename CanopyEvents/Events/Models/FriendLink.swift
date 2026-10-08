/// Your friend link (the API's `FriendLink`): share `url`, or show it as a
/// QR code whose text is exactly `url`. Whoever opens it and says yes is
/// in your list and you're in theirs.
nonisolated struct FriendLink: Codable, Hashable, Sendable {
    /// `https://events.canopysf.com/f/<code>`.
    var url: String
    var code: String
}
