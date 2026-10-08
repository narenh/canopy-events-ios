import Foundation

/// The cast of the mock world. Maya is the main signed-in account; Sam is
/// a brand-new quick (unverified) account with almost no history.
enum MockPeople {
    // MARK: Signed-in accounts

    static let maya = Me(
        id: "p-maya", email: "maya@example.com", firstName: "Maya", lastName: "Chen",
        shortName: "Maya C", photoUrl: photo(47), phone: "+14155550123",
        instagram: "maya.chen", venmo: "maya-chen", cashapp: nil,
        emailVerified: true, findable: true
    )

    /// An unverified quick account with one invite and one RSVP.
    static let sam = quickUser(id: "p-sam", firstName: "Sam", lastName: "Rivera", email: "sam@example.com")

    /// An unverified quick account with no history at all, for empty states.
    /// Not in the backend's seed; `mockEnvironment(signedInAs:)` adds it.
    static let ada = quickUser(id: "p-ada", firstName: "Ada", lastName: "Ng", email: "ada@example.com")

    /// A quick sign-up: name and email only, email not yet verified.
    static func quickUser(id: String, firstName: String, lastName: String, email: String) -> Me {
        Me(
            id: id, email: email, firstName: firstName, lastName: lastName,
            shortName: PersonName.short(firstName: firstName, lastName: lastName),
            photoUrl: nil, phone: nil, instagram: nil, venmo: nil, cashapp: nil,
            emailVerified: false, findable: true
        )
    }

    // MARK: Everyone else

    static let ana = person("p-ana", "Ana", "Lima", photo: 5)
    static let ben = person("p-ben", "Ben", "Okafor", photo: 12)
    static let chloe = person("p-chloe", "Chloe", "Martin")
    static let diego = person("p-diego", "Diego", "Ramos", photo: 33)
    static let elif = person("p-elif", "Elif", "Yilmaz")
    static let farah = person("p-farah", "Farah", "Haddad", photo: 44)
    static let gus = person("p-gus", "Gus", "Novak")
    static let hana = person("p-hana", "Hana", "Sato", photo: 25)
    static let isaac = person("p-isaac", "Isaac", "Brooks")
    static let jules = person("p-jules", "Jules", "Moreau", photo: 15)
    static let kofi = person("p-kofi", "Kofi", "Mensah")
    static let lena = person("p-lena", "Lena", "Park", photo: 20)
    /// The host of the test notification's invite. No photo: his avatar
    /// is his initials, drawn for the notification too.
    static let karl = person("p-karl", "Karl", "Marx")

    static let everyone = [ana, ben, chloe, diego, elif, farah, gus, hana, isaac, jules, kofi, lena, karl]

    // MARK: Helpers

    private static func person(_ id: String, _ first: String, _ last: String, photo: Int? = nil) -> Person {
        Person(
            id: id, firstName: first, lastName: last,
            shortName: PersonName.short(firstName: first, lastName: last),
            photoUrl: photo.flatMap(Self.photo)
        )
    }

    /// Placeholder portraits from pravatar.cc; the avatar falls back to
    /// initials when they can't load (offline, previews).
    private static func photo(_ number: Int) -> URL? {
        URL(string: "https://i.pravatar.cc/200?img=\(number)")
    }
}
