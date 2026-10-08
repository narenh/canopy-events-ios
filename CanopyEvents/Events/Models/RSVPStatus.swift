/// Where someone stands on an event. The raw values are the API's.
///
/// `invited` means invited with no answer yet. `waitlisted` is a `going`
/// that arrived after the event was full.
nonisolated enum RSVPStatus: String, Codable, Hashable, CaseIterable, Identifiable {
    case invited
    case going
    case maybe
    case notGoing = "not_going"
    case waitlisted

    var id: Self { self }

    /// The three answers a guest can pick.
    static let answers: [RSVPStatus] = [.going, .maybe, .notGoing]

    var title: String {
        switch self {
        case .invited: "Invited"
        case .going: "Going"
        case .maybe: "Maybe"
        case .notGoing: "Can't go"
        case .waitlisted: "Waitlisted"
        }
    }

    var systemImage: String {
        switch self {
        case .invited: "envelope"
        case .going: "checkmark.circle.fill"
        case .maybe: "questionmark.circle.fill"
        case .notGoing: "xmark.circle.fill"
        case .waitlisted: "hourglass"
        }
    }
}
