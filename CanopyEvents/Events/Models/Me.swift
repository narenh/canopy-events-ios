import Foundation

/// You, the signed-in person, with your own contact details. Only ever
/// comes from `GET /api/v1/me`. Matches the API's `Me` schema.
nonisolated struct Me: Codable, Hashable, Identifiable {
    var id: String
    var email: String?
    var firstName: String
    var lastName: String
    var shortName: String
    var photoUrl: URL?
    var phone: String?
    var instagram: String?
    var venmo: String?
    var cashapp: String?
    /// False for a quick account whose email isn't proven yet.
    /// While false, show the verify banner (it can't be dismissed).
    var emailVerified: Bool
    /// Whether people who know your phone or Instagram can find you.
    var findable: Bool?

    /// You, in the public shape everyone else sees.
    var person: Person {
        Person(id: id, firstName: firstName, lastName: lastName, shortName: shortName, photoUrl: photoUrl)
    }
}
