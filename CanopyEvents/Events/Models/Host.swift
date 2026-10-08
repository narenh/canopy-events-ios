/// One of an event's hosts (the API's `Host`): the creator first, then
/// co-hosts in the order they were added.
nonisolated struct Host: Codable, Hashable, Identifiable {
    var person: Person
    var role: HostRole

    var id: Person.ID { person.id }
}
