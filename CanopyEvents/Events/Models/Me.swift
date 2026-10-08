import Foundation

/// You, as the events API has you (`GET /api/v1/me`'s `person`, the API's
/// `Me`): no email, phone, Instagram, Venmo or Cash App, not even your
/// own (events never shows them). Those come from the Canopy Account
/// service (`AccountProfile`, through `AccountService`).
nonisolated struct Me: Codable, Hashable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var shortName: String
    var photoUrl: URL?
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
