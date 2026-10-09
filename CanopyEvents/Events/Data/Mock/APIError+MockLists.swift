import Foundation

/// The lists' errors the mock throws, worded as canopy-events'
/// public/copy.js words them where it has a sentence.
extension APIError {
    static let badListName = APIError(message: "A list's name is 1 to 60 characters.", reason: .badName)
    static let listNotFound = APIError(message: "That list isn't there.", reason: .listNotFound)
    static let listLinkNotFound = APIError(message: "This list's link doesn't work any more. It may have been reset.", reason: .listLinkNotFound)
    static let notAMember = APIError(message: "They aren't on that list.", reason: .notAMember)
    static let notYourList = APIError(message: "Only its owner or the person who made this event can take that list off.", reason: .notYourList)
    static let ownList = APIError(message: "That's your own list.", reason: .ownList)
    static let tooManyLists = APIError(message: "That's as many lists as you can have.", reason: .tooManyLists)
    static let tooManyListsOnEvent = APIError(message: "An event can have at most 10 lists.", reason: .tooManyLists)
    static let listFull = APIError(message: "That list is full.", reason: .listFull)
    static let badListPersonIds = APIError(message: "Add 1 to 100 people at a time.", reason: .badPersonIds)
}
