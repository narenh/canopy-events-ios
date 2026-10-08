/// The Attending section's words and order, as the web has them
/// (`attendSummary`, `attendPeople`).
nonisolated enum Attending {
    /// "4 Going · 2 Maybe", then "· 3 Waitlist" when there's one, then the
    /// plus-ones going and maybe bring ("· +3 guests"). People, not seats.
    static func summary(_ counts: RSVPCounts) -> String {
        var parts = ["\(counts.going) Going", "\(counts.maybe) Maybe"]
        if counts.waitlisted > 0 { parts.append("\(counts.waitlisted) Waitlist") }
        let guests = counts.guests.going + counts.guests.maybe
        if guests > 0 { parts.append(guests == 1 ? "+1 guest" : "+\(guests) guests") }
        return parts.joined(separator: " · ")
    }

    /// Who's in the row, in order: friends going first, then going, then
    /// maybe, the most recent answer first in each (the guest list comes
    /// oldest first). Nobody twice.
    static func people(friends: [Person], guests: [Guest]) -> [Person] {
        var seen = Set<Person.ID>()
        var out: [Person] = []
        func add(_ person: Person) {
            if seen.insert(person.id).inserted { out.append(person) }
        }
        friends.forEach(add)
        for status in [RSVPStatus.going, .maybe] {
            guests.filter { $0.status == status }.reversed().forEach { add($0.person) }
        }
        return out
    }
}
