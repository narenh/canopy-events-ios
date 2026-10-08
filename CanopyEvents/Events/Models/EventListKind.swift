/// The lists of "my events", one per API endpoint
/// (`/api/v1/me/events/<rawValue>`).
nonisolated enum EventListKind: String, Codable, Hashable, CaseIterable, Identifiable {
    /// Events you host that aren't over, cancelled ones included.
    case hosting
    /// Going, maybe or waitlisted, not over; cancelled ones stay.
    case upcoming
    /// Invited with no answer, not over, not cancelled.
    case invitations
    /// You said can't go, not over, not cancelled.
    case declined
    /// Over, and you hosted or said going or maybe. Most recent first.
    case past

    var id: Self { self }

    var title: String {
        switch self {
        case .upcoming: "Upcoming"
        case .invitations: "Invites"
        case .hosting: "Hosting"
        case .past: "Past events"
        case .declined: "Declined"
        }
    }
}
