/// Where someone stands on an event (the API's `RsvpStatus`). The raw
/// values are the API's.
///
/// `invited` means invited with no answer yet. `waitlisted` is a `going`
/// that didn't fit the event's capacity; the server moves it to `going`
/// when a spot that fits frees up, and nobody asks for it. `removed` is a
/// host having taken someone off the event: you only see it as your own
/// `viewer.rsvp`, and hosts see it on the guest list with `?status=removed`.
nonisolated enum RSVPStatus: String, Codable, Hashable, CaseIterable, Identifiable {
    case invited
    case going
    case maybe
    case notGoing = "not_going"
    case waitlisted
    case removed

    var id: Self { self }

    /// The three answers a guest can pick (the API's `RsvpInput.status`).
    static let answers: [RSVPStatus] = [.going, .maybe, .notGoing]

    var title: String {
        switch self {
        case .invited: "Invited"
        case .going: "Going"
        case .maybe: "Maybe"
        case .notGoing: "Can't go"
        case .waitlisted: "Waitlisted"
        case .removed: "Removed"
        }
    }

    var systemImage: String {
        switch self {
        case .invited: "envelope"
        case .going: "checkmark.circle.fill"
        case .maybe: "questionmark.circle.fill"
        case .notGoing: "xmark.circle.fill"
        case .waitlisted: "hourglass"
        case .removed: "nosign"
        }
    }

    /// Whether this is an answer (so the guest list's names show to you
    /// under `responded`). Not `invited`, and not `removed`.
    var isAnswer: Bool {
        switch self {
        case .going, .maybe, .notGoing, .waitlisted: true
        case .invited, .removed: false
        }
    }

    /// Whether this answer may post on the wall: going, maybe or waitlisted.
    var canPost: Bool {
        self == .going || self == .maybe || self == .waitlisted
    }
}
