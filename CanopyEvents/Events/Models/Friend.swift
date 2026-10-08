import Foundation

/// Someone you've been at an event with (the API's `Friend`): both of you
/// hosting or going, on an event that started and wasn't cancelled.
/// There are no friend requests.
nonisolated struct Friend: Codable, Hashable, Identifiable {
    var person: Person
    var eventsInCommon: Int
    /// When the latest of those events started.
    var lastTogetherAt: Date

    var id: Person.ID { person.id }
}
