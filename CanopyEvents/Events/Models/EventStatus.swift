/// Whether an event is on. A cancelled event keeps its link and guest
/// list; there's no deleting. The creator can take a cancel back.
nonisolated enum EventStatus: String, Codable, Hashable {
    case active
    case cancelled
}
