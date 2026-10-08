import Foundation

/// Anyone other than you. This is the only shape another person ever has:
/// the API never sends someone else's email, phone or handles, and the app
/// never asks for them. Matches the API's `Person` schema.
nonisolated struct Person: Codable, Hashable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    /// First name and last initial, e.g. "Ana L". Sent by the server.
    var shortName: String
    var photoUrl: URL?

    var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
