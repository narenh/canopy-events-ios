import Foundation

/// You, as the Canopy Account service has you (`GET /api/native/v1/me`'s
/// `person`): your own contact details too, which only you ever see.
/// The Profile reads and edits these; the rest of the app uses `Me`.
nonisolated struct AccountProfile: Codable, Hashable, Identifiable {
    var id: String
    var email: String
    var emailVerified: Bool
    var firstName: String
    var lastName: String
    var shortName: String
    var photoUrl: URL?
    var venmo: String?
    /// E.164, e.g. "+14155551234".
    var phone: String?
    /// Without the @.
    var instagram: String?
    var cashapp: String?
    var findable: Bool
    /// The admin uses the web for that.
    var isAdmin: Bool

    /// The events API's view of you.
    var me: Me {
        Me(id: id, firstName: firstName, lastName: lastName, shortName: shortName, photoUrl: photoUrl,
           emailVerified: emailVerified, findable: findable)
    }

    var person: Person { me.person }
}
