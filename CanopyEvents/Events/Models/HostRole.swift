/// A host's part in an event: the person who made it, or a co-host.
/// Co-hosts can edit and invite; only the creator manages co-hosts,
/// cancels and makes a new link.
nonisolated enum HostRole: String, Codable, Hashable {
    case creator
    case cohost

    var title: String {
        switch self {
        case .creator: "Host"
        case .cohost: "Co-host"
        }
    }
}
