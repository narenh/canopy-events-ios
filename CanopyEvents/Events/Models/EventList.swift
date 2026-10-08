/// A page of one of your event lists (the API's `EventList`). Each event
/// has `viewer` but no `friendsGoing`.
nonisolated struct EventList: Codable, Hashable {
    var events: [Event]
    /// Pass back for the next page; nil at the end.
    var nextCursor: String?
}
