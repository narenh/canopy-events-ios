import Foundation

/// More of the mock world: the Drag Race regulars and the climbing crowd,
/// so there are 30-odd friends to invite and lists worth the name. Some
/// have photos, some initials; a few names have accents (search ignores
/// them).
extension MockPeople {
    static let priya = person("p-priya", "Priya", "Kapoor", photo: 9)
    static let theo = person("p-theo", "Theo", "Albrecht", photo: 53)
    static let ines = person("p-ines", "Inés", "Duarte", photo: 16)
    static let marcus = person("p-marcus", "Marcus", "Bell")
    static let noor = person("p-noor", "Noor", "Rahman", photo: 29)
    static let oscar = person("p-oscar", "Oscar", "Lindqvist", photo: 60)
    static let quinn = person("p-quinn", "Quinn", "Delaney")
    static let rosa = person("p-rosa", "Rosa", "Esposito", photo: 38)
    static let sven = person("p-sven", "Sven", "Halvorsen")
    static let tomas = person("p-tomas", "Tomás", "Herrera", photo: 59)
    static let uma = person("p-uma", "Uma", "Venkatesan")
    static let vic = person("p-vic", "Vic", "Okonkwo", photo: 65)
    static let wren = person("p-wren", "Wren", "Callahan", photo: 32)
    static let xavier = person("p-xavier", "Xavier", "Moreno")
    static let yuki = person("p-yuki", "Yuki", "Tanaka", photo: 26)
    static let zane = person("p-zane", "Zane", "Whitfield")
    static let amara = person("p-amara", "Amara", "Osei", photo: 41)
    static let bea = person("p-bea", "Bea", "Laurent")
    static let cyrus = person("p-cyrus", "Cyrus", "Farahani", photo: 68)
    static let dani = person("p-dani", "Dani", "Kowalski", photo: 23)
    static let emeka = person("p-emeka", "Emeka", "Nwosu")
    static let freya = person("p-freya", "Freya", "Lund", photo: 45)
    static let gio = person("p-gio", "Gio", "Russo")
    static let hugo = person("p-hugo", "Hugo", "Brandt", photo: 57)

    /// Everyone above.
    static let crowd = [priya, theo, ines, marcus, noor, oscar, quinn, rosa, sven, tomas, uma, vic,
                        wren, xavier, yuki, zane, amara, bea, cyrus, dani, emeka, freya, gio, hugo]

    /// Rosa can be found by her number or Instagram (she isn't anyone's
    /// friend yet), so the invite sheet's lookup has someone to find:
    /// (415) 555-0188 or @rosa.e.
    static let rosaAccount = AccountProfile(
        id: rosa.id, email: "rosa@example.com", emailVerified: true, firstName: rosa.firstName, lastName: rosa.lastName,
        shortName: rosa.shortName, photoUrl: rosa.photoUrl, venmo: nil, phone: "+14155550188",
        instagram: "rosa.e", cashapp: nil, findable: true, isAdmin: false
    )
}
