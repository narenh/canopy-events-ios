/// The answer to putting a list on an event (the API's `ListAttached`):
/// the event, with the list in its `hostLists`, and how many people were
/// invited just now.
nonisolated struct ListAttached: Codable, Hashable {
    var event: Event
    var invitedCount: Int
}
