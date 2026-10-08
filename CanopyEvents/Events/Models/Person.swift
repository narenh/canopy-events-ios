import Foundation

/// Anyone other than you (the API's `Person`). This is the only shape
/// another person ever has: the API never sends someone else's email,
/// phone or handles, and the app never asks for them. A deleted account
/// is a "Former member" with an empty last name and no photo.
nonisolated struct Person: Codable, Hashable, Identifiable {
    /// The account service's UUID.
    var id: String
    var firstName: String
    var lastName: String
    /// First name and last initial, e.g. "Ana L". Sent by the server.
    var shortName: String
    /// On account.canopysf.com, loaded with the session; nil for no photo.
    var photoUrl: URL?

    var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
