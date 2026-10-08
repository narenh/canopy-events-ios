/// How many people are in each status. Always visible to everyone, even
/// when the guest list's names are hidden. Hosts aren't counted.
/// (The API calls this `Counts`.)
nonisolated struct RSVPCounts: Codable, Hashable {
    var going = 0
    var maybe = 0
    var notGoing = 0
    var invited = 0
    var waitlisted = 0

    func count(for status: RSVPStatus) -> Int {
        switch status {
        case .invited: invited
        case .going: going
        case .maybe: maybe
        case .notGoing: notGoing
        case .waitlisted: waitlisted
        }
    }
}
