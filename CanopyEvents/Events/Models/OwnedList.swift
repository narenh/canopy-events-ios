import Foundation

/// One of your lists (the API's `OwnedList`): people who joined it
/// themselves, by its link or QR code, for inviting them all at once.
/// Only you see who's on it and how many.
nonisolated struct OwnedList: Codable, Hashable, Identifiable {
    /// For the API only; never in a link.
    var id: String
    var name: String
    /// The join link's code. Resetting the link changes it, not `id`.
    var code: String
    /// `https://events.canopysf.com/l/<code>`: what's shared, and the text
    /// of its QR code.
    var url: String
    var memberCount: Int
    var createdAt: Date
}
