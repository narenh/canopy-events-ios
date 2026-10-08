import Foundation

/// One face in an expanded invite's Attending row: a name for the
/// initials, and a photo when there is one.
nonisolated struct CardFace: Codable, Hashable, Sendable {
    var name: String
    var photoUrl: URL?

    /// "AL" from "Ana Lima".
    var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }
}
