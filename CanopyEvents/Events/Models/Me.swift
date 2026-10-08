import Foundation

/// You, the signed-in person, with your own contact details (the events
/// API's `Me`). Only ever comes from `GET /api/v1/me`. The account
/// service's own `person` decodes into this too (its extra `isAdmin` is
/// ignored, and its `email` and `findable` are never null).
nonisolated struct Me: Codable, Hashable, Identifiable {
    var id: String
    var email: String?
    var firstName: String
    var lastName: String
    var shortName: String
    var photoUrl: URL?
    /// E.164, e.g. "+14155551234".
    var phone: String?
    /// Without the @.
    var instagram: String?
    var venmo: String?
    var cashapp: String?
    /// False for a quick account whose email isn't proven yet.
    /// While false, show the verify banner (it can't be dismissed).
    var emailVerified: Bool
    /// Whether people who know your phone or Instagram can find you.
    /// Nil if the account service didn't say.
    var findable: Bool?

    /// You, in the public shape everyone else sees.
    var person: Person {
        Person(id: id, firstName: firstName, lastName: lastName, shortName: shortName, photoUrl: photoUrl)
    }
}
