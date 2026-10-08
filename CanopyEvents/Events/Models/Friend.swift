import Foundation

/// Someone in your friends list (the API's `Friend`). One way, like
/// following: being in yours doesn't put you in theirs, and only you see
/// your list.
nonisolated struct Friend: Codable, Hashable, Identifiable {
    var person: Person
    var source: FriendSource
    /// 0 for someone you only added (or linked, or invited).
    var eventsInCommon: Int
    /// When the latest event you were both at started; nil with none.
    var lastTogetherAt: Date?

    var id: Person.ID { person.id }
}
