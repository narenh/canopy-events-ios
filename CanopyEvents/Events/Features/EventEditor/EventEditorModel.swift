import Foundation
import Observation

/// The editor's state: a draft of the event's fields, a cover picked or
/// removed (sent only on Save), and saving it all through the repository.
/// A copy (`duplicating:`) is a new event filled in from its draft. The
/// date and times are in `+When`.
@Observable
final class EventEditorModel {
    /// The event being edited, or nil when making a new one.
    let original: Event?
    /// What a copy started from, or nil: its cover shows until it's
    /// taken off or replaced, and its lists are offered once it's made.
    let duplicate: DuplicateDraft?
    var draft: EventDraft
    /// A start time picked before the day, on the event's clock.
    var pendingStartTime: ClockTime?
    /// A photo picked for the cover, not uploaded until Save.
    private(set) var pickedCover: Data?
    /// The color that matches the picked photo, once worked out.
    private(set) var pickedCoverTheme: EventTheme?
    /// The saved cover is to go, on Save.
    private(set) var removesCover = false
    /// A TMDB background chosen for the cover, sent on Save (after a new
    /// event is made), as a picked photo is.
    private(set) var pickedBackground: Background?
    private(set) var isSaving = false
    var errorMessage: String?

    init(event: Event?) {
        original = event
        duplicate = nil
        draft = event.map(EventDraft.init(event:)) ?? .blank()
    }

    /// A new event filled in from a copy's draft, with no date or times.
    init(duplicating duplicate: DuplicateDraft) {
        original = nil
        self.duplicate = duplicate
        draft = EventDraft(duplicate: duplicate)
    }

    var isNew: Bool { original == nil }

    /// Whether the hero shows a photo (picked, the saved one kept, or a
    /// copy's original's).
    var hasCover: Bool {
        pickedCover != nil || pickedBackground != nil || draft.coverFrom != nil
            || (original?.hasCover == true && !removesCover)
    }

    /// The color "Match photo" applies: the picked photo's, else the
    /// saved cover's (its `coverHue`) or a copy's original's, or nil when
    /// it isn't known.
    var coverMatch: EventTheme? {
        if pickedCover != nil { return pickedCoverTheme }
        if let pickedBackground { return pickedBackground.theme }
        if draft.coverFrom != nil { return duplicate?.coverTheme }
        return removesCover ? nil : original?.coverTheme
    }

    // MARK: Cover and color

    /// A photo was picked: keep it for Save, and jump the color to it
    /// when its color can be worked out (the host can still change it).
    func pick(_ data: Data) {
        pickedCover = data
        pickedBackground = nil
        draft.coverFrom = nil
        removesCover = false
        pickedCoverTheme = PhotoHue.theme(ofImageData: data)
        if let pickedCoverTheme { draft.theme = pickedCoverTheme }
    }

    /// A background chosen: preview it, and jump the color to its own.
    func pick(_ background: Background) {
        pickedBackground = background
        pickedCover = nil
        pickedCoverTheme = nil
        draft.coverFrom = nil
        removesCover = false
        draft.theme = background.theme
    }

    func removeCover() {
        pickedCover = nil
        pickedBackground = nil
        pickedCoverTheme = nil
        draft.coverFrom = nil
        removesCover = original?.hasCover == true
    }

    func matchPhoto() {
        if let coverMatch { draft.theme = coverMatch }
    }

    // MARK: Saving

    /// Creates or updates the event (a copy with its original's cover,
    /// unless taken off or replaced), then uploads or removes its cover.
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
            } else if let pickedBackground {
                event = try await repository.setCoverBackground(eventId: event.id, backgroundId: pickedBackground.id)
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
