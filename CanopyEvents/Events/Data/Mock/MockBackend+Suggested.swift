import Foundation

/// Who to suggest first when inviting (docs/api.md, `GET
/// /me/friends/suggested`): each event you were both at adds
/// `2^(-days since it started / 90)`, doubled for one you hosted; a way in
/// other than events adds a little, fading the same way from when it was
/// made (an invitation 0.5, a friend link or adding by id 0.25).
extension MockBackend {
    static let halfLifeDays = 90.0
    static let hostedWeight = 2.0

    /// Your friends with a score above 0, best first; ties go to whoever
    /// you were with last, then by id.
    func suggestedFriends(of me: Person, now: Date = .now) -> [SuggestedFriend] {
        var scores: [Person.ID: Double] = [:]
        for record in records where record.event.startsAt < now && !record.event.isCancelled {
            let present = record.event.hosts.map(\.person.id) + record.guests.filter { $0.status == .going }.map(\.person.id)
            guard present.contains(me.id) else { continue }
            let weight = Self.fading(since: record.event.startsAt, now: now) * (record.isHost(me.id) ? Self.hostedWeight : 1)
            for id in present where id != me.id { scores[id, default: 0] += weight }
        }
        for (id, source) in friendEdges[me.id, default: [:]] {
            let base = source == .invite ? 0.5 : source == .sharedEvents ? 0 : 0.25
            let made = friendEdgeDates[me.id]?[id] ?? now
            scores[id, default: 0] += base * Self.fading(since: made, now: now)
        }
        return friends(of: me)
            .compactMap { friend -> SuggestedFriend? in
                let score = ((scores[friend.id] ?? 0) * 1000).rounded() / 1000
                guard score > 0 else { return nil }
                return SuggestedFriend(person: friend.person, source: friend.source, eventsInCommon: friend.eventsInCommon,
                                       lastTogetherAt: friend.lastTogetherAt, score: score)
            }
            .sorted {
                if $0.score != $1.score { return $0.score > $1.score }
                let (a, b) = ($0.lastTogetherAt ?? .distantPast, $1.lastTogetherAt ?? .distantPast)
                return a != b ? a > b : $0.id < $1.id
            }
    }

    /// 1 now, a half after 90 days, a quarter after 180.
    static func fading(since date: Date, now: Date) -> Double {
        pow(2, -max(0, now.timeIntervalSince(date)) / 86_400 / halfLifeDays)
    }
}
