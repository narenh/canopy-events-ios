import Foundation

/// Where an event is in its life, as the web's `phaseOf` says: cancelled,
/// over, happening now (started, not over) or still to come.
nonisolated enum EventPhase: Hashable {
    case upcoming
    case now
    case over
    case cancelled

    init(event: Event, now: Date = .now) {
        if event.isCancelled {
            self = .cancelled
        } else if event.effectiveEnd <= now {
            self = .over
        } else if event.startsAt <= now {
            self = .now
        } else {
            self = .upcoming
        }
    }

    /// Still takes answers and invitations.
    var isOpen: Bool { self == .upcoming || self == .now }
}
