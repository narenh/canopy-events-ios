import Foundation

/// A friend with their suggestion `score` (the API's `SuggestedFriend`,
/// from `GET /api/v1/me/friends/suggested`): the people you've been with
/// most and most recently, more so the guests of events you hosted.
nonisolated struct SuggestedFriend: Codable, Hashable, Identifiable {
    var person: Person
    var source: FriendSource
    var eventsInCommon: Int
    var lastTogetherAt: Date?
    /// Above 0; higher first.
    var score: Double

    var id: Person.ID { person.id }

    /// The same person as a plain `Friend`.
    var friend: Friend {
        Friend(person: person, source: source, eventsInCommon: eventsInCommon, lastTogetherAt: lastTogetherAt)
    }
}
