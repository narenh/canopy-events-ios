import Foundation
import Observation

/// The editor's state: a draft of the event's fields, a cover picked or
/// removed (sent only on Save), and saving it all through the repository.
@Observable
final class EventEditorModel {
    /// The event being edited, or nil when making a new one.
    let original: Event?
    var draft: EventDraft
    /// A photo picked for the cover, not uploaded until Save.
    private(set) var pickedCover: Data?
    /// The color that matches the picked photo, once worked out.
    private(set) var pickedCoverTheme: EventTheme?
    /// The saved cover is to go, on Save.
    private(set) var removesCover = false
    private(set) var isSaving = false
    var errorMessage: String?

    init(event: Event?) {
        original = event
        draft = event.map(EventDraft.init(event:)) ?? .blank()
    }

    var isNew: Bool { original == nil }

    /// Whether the hero shows a photo (picked, or the saved one kept).
    var hasCover: Bool { pickedCover != nil || (original?.hasCover == true && !removesCover) }

    /// The color "Match photo" applies: the picked photo's, else the
    /// saved cover's (its `coverHue`), or nil when it isn't known.
    var coverMatch: EventTheme? {
        if pickedCover != nil { return pickedCoverTheme }
        return removesCover ? nil : original?.coverTheme
    }

    // MARK: When

    /// Moving the start moves the end with it, keeping the length.
    func setStart(_ start: Date) {
        if let end = draft.endsAt {
            draft.endsAt = start.addingTimeInterval(end.timeIntervalSince(draft.startsAt))
        }
        draft.startsAt = start
    }

    /// "+ End time": three hours after the start.
    func addEnd() {
        draft.endsAt = draft.startsAt.addingTimeInterval(3 * 60 * 60)
    }

    func removeEnd() {
        draft.endsAt = nil
    }

    // MARK: Cover and color

    /// A photo was picked: keep it for Save, and jump the color to it
    /// when its color can be worked out (the host can still change it).
    func pick(_ data: Data) {
        pickedCover = data
        removesCover = false
        pickedCoverTheme = PhotoHue.theme(ofImageData: data)
        if let pickedCoverTheme { draft.theme = pickedCoverTheme }
    }

    func removeCover() {
        pickedCover = nil
        pickedCoverTheme = nil
        removesCover = original?.hasCover == true
    }

    func matchPhoto() {
        if let coverMatch { draft.theme = coverMatch }
    }

    // MARK: Saving

    /// Creates or updates the event, then uploads or removes its cover.
    /// Returns it on success.
    func save(using repository: any EventsRepository) async -> Event? {
        isSaving = true
        defer { isSaving = false }
        do {
            var event = if let original {
                try await repository.updateEvent(id: original.id, with: draft)
            } else {
                try await repository.createEvent(draft)
            }
            if let pickedCover {
                event = try await repository.setCover(eventId: event.id, imageData: pickedCover)
            } else if removesCover {
                event = try await repository.deleteCover(eventId: event.id)
            }
            return event
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
