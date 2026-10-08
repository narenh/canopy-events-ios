import Foundation

/// A list on an event, as its hosts see it (the API's `HostList`), in the
/// order they were put on. Its `url` is for a big QR code at the door.
nonisolated struct HostList: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var code: String
    var url: String
    var owner: Person
    var isYours: Bool
    /// Only for your own lists; nil for a co-host's.
    var memberCount: Int?
    var attachedAt: Date
}
