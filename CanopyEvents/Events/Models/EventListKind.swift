/// The lists of "my events", one per API endpoint
/// (`/api/v1/me/events/<rawValue>`). `declined` isn't in the API spec
/// yet; the Invites tab needs it (see ARCHITECTURE.md).
nonisolated enum EventListKind: String, Codable, Hashable, CaseIterable, Identifiable {
    case upcoming
    case invitations
    case hosting
    case past
    case declined

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
