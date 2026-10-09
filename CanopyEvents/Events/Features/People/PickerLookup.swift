/// The found-by-lookup line at the top of the invite sheet: looking, the
/// person, nobody, or why it couldn't look; for one typed text.
struct InviteLookup: Equatable {
    enum State: Equatable {
        case looking
        case found(Person.ID)
        case none
        case failed(String)
    }

    var query: String
    var state: State

    /// The web's words for the lookup's refusals (public/copy.js,
    /// `invite.lookupErrors`); nil for anything else.
    static func words(for reason: APIErrorReason) -> String? {
        switch reason {
        case .badPhone: "That doesn't look like a phone number."
        case .badInstagram: "An Instagram username is letters, numbers, dots and underscores."
        case .oneOf: "Type a phone number or an Instagram username."
        case .rateLimited: "That's a lot of lookups. Try again later."
        case .emailUnverified: "Confirm your email to find people by phone number or Instagram."
        case .lookupNotAllowed: "Finding people by phone number or Instagram isn't available yet."
        default: nil
        }
    }
}
