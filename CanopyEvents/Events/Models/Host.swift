/// One of an event's hosts. The creator comes first.
nonisolated struct Host: Codable, Hashable, Identifiable {
    var person: Person
    var role: HostRole

    var id: Person.ID { person.id }
}
