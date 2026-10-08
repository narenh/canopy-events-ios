import Foundation

/// One thing on an event's activity wall (the API's `WallEntry`): a post,
/// or one of the server's own entries ("Ana is going", "Time changed").
nonisolated struct WallEntry: Codable, Hashable, Identifiable {
    /// Digits, e.g. "42".
    var id: String
    var type: WallEntryType
    var createdAt: Date
    /// Who wrote the post, or whom the entry is about (the host who moved
    /// it, the person going, the new co-host).
    var person: Person?
    /// A post's text, plain (never HTML); nil for every other type.
    var text: String?
    /// The new time or place, for `time_changed` and `place_changed`.
    var details: WallEntryDetails?
    /// Your own post, or anything if you're a host.
    var canDelete: Bool

    /// False for a type this app doesn't know, which it shouldn't show.
    var isKnown: Bool { type != .unknown }
}
