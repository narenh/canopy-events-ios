import Foundation
import Observation

/// Loads one or more of "my events" lists and merges them, soonest first
/// (most recent first for past events). Shared by the Events, Past,
/// Invites and Declined screens; each makes its own with the lists it shows.
@Observable
final class EventListModel {
    let kinds: [EventListKind]
    private(set) var events: [Event] = []
    private(set) var hasLoaded = false
    var errorMessage: String?

    init(_ kinds: EventListKind...) {
        self.kinds = kinds
    }

    func load(from repository: any EventsRepository) async {
        do {
            var merged: [Event.ID: Event] = [:]
            for kind in kinds {
                for event in try await repository.allEvents(kind) {
                    merged[event.id] = event
                }
            }
            let newestFirst = kinds == [.past]
            events = merged.values.sorted { newestFirst ? $0.startsAt > $1.startsAt : $0.startsAt < $1.startsAt }
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Answers an event from its row, then reloads (the answer may move it
    /// to another list).
    func answer(_ event: Event, with status: RSVPStatus, using repository: any EventsRepository) async {
        do {
            _ = try await repository.setRSVP(eventId: event.id, status: status, guests: 0)
            await load(from: repository)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
