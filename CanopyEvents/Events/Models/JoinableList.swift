/// A list on an event that you aren't on and could join (the API's
/// `JoinableList`), for the "Get invited next time" card. Joining is
/// `POST /api/v1/list-links/{code}/join`.
nonisolated struct JoinableList: Codable, Hashable {
    var code: String
    var name: String
    var url: String
    /// One of the event's hosts.
    var owner: Person
}
