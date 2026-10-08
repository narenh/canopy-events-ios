import Foundation

/// The errors the mock throws, with the real `reason`s and a sentence to
/// show. The real server writes its own sentences.
extension APIError {
    // MARK: Events API

    static let signInRequired = APIError(message: "Sign in first.", reason: .signInRequired)
    static let eventNotFound = APIError(message: "There's no event at that link.", reason: .eventNotFound)
    static let eventCancelled = APIError(message: "This event has been cancelled.", reason: .eventCancelled)
    static let eventOver = APIError(message: "This event is over.", reason: .eventOver)
    static let hostCannotRSVP = APIError(message: "Hosts don't RSVP to their own event.", reason: .hostCannotRSVP)
    static let hostsOnly = APIError(message: "Only hosts can do that.", reason: .hostsOnly)
    static let creatorOnly = APIError(message: "Only the person who made the event can do that.", reason: .creatorOnly)
    static let tooManyGuests = APIError(message: "That's more plus-ones than the host allows.", reason: .tooManyGuests)
    static let noRoom = APIError(message: "There isn't room for more plus-ones. Your spot is as it was.", reason: .noRoom)
    static let removed = APIError(message: "A host took you off this event.", reason: .removed)
    static let answerFirst = APIError(message: "Say you're going or maybe first.", reason: .answerFirst)
    static let notYours = APIError(message: "That isn't your post.", reason: .notYours)
    static let badText = APIError(message: "Posts are 1 to 1,000 characters.", reason: .badText)
    static let entryNotFound = APIError(message: "That post is gone.", reason: .entryNotFound)
    static let notInvited = APIError(message: "They weren't invited.", reason: .notInvited)
    static let alreadyResponded = APIError(message: "They've already answered.", reason: .alreadyResponded)
    static let personNotFound = APIError(message: "There's no Canopy account with that id.", reason: .personNotFound)
    static let notCohost = APIError(message: "They aren't a co-host.", reason: .notCohost)
    static let notRemoved = APIError(message: "They weren't removed.", reason: .notRemoved)
    static let isCreator = APIError(message: "You already host this event.", reason: .isCreator)
    static let isHost = APIError(message: "Hosts can't be removed.", reason: .isHost)
    static let tooManyCohosts = APIError(message: "An event can have at most 10 co-hosts.", reason: .tooManyCohosts)
    static let oneOf = APIError(message: "Look up by a phone number or an Instagram handle.", reason: .oneOf)
    static let emailUnverified = APIError(
        message: "Verify your email first.", reason: .emailUnverified,
        verify: URL(string: "https://account.canopysf.com/profile?verify=1")
    )
    /// Making someone a co-host who isn't known to be verified: no `verify` link.
    static let cohostUnverified = APIError(
        message: "They need to open an event link with a verified email first.", reason: .emailUnverified
    )

    // MARK: Account service

    static let wrongCode = APIError(message: "That code isn't right. (Mock: any six digits work.)", reason: .wrongCode)
    static func emailHasAccount(_ email: String) -> APIError {
        APIError(message: "That email has an account. Sign in instead.", reason: .emailHasAccount, email: email)
    }
}
