import Foundation
import Observation

/// The create/edit form's state: a draft of the event's fields, and
/// saving or cancelling it through the repository.
@Observable
final class EventEditorModel {
    /// The event being edited, or nil when making a new one.
    let original: Event?
    var draft: EventDraft
    private(set) var isSaving = false
    var errorMessage: String?

    init(event: Event?) {
        original = event
        draft = event.map(EventDraft.init(event:)) ?? .blank()
    }

    var isNew: Bool { original == nil }

    /// The form's "Ends" toggle. Turning it on picks start + 3 hours.
    var hasEndTime: Bool {
        get { draft.endsAt != nil }
        set { draft.endsAt = newValue ? draft.startsAt.addingTimeInterval(3 * 60 * 60) : nil }
    }

    /// The form's "Limit spots" toggle. Turning it on starts at 20.
    var hasCapacity: Bool {
        get { draft.capacity != nil }
        set { draft.capacity = newValue ? 20 : nil }
    }

    /// Creates or updates the event. Returns it on success.
    func save(using repository: any EventsRepository) async -> Event? {
        isSaving = true
        defer { isSaving = false }
        do {
            if let original {
                return try await repository.updateEvent(id: original.id, with: draft)
            } else {
                return try await repository.createEvent(draft)
            }
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// Cancels the event (it keeps its link and guest list).
    func cancelEvent(using repository: any EventsRepository) async -> Event? {
        guard let original else { return nil }
        isSaving = true
        defer { isSaving = false }
        do {
            return try await repository.cancelEvent(id: original.id)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
