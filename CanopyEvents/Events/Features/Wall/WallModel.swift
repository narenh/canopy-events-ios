import Foundation
import Observation

/// An event's activity wall: loading it, posting, deleting an entry.
@Observable
final class WallModel {
    let eventId: Event.ID
    private(set) var wall: Wall?
    private(set) var isPosting = false
    /// What's typed in the composer.
    var draft = ""
    var errorMessage: String?

    init(eventId: Event.ID) {
        self.eventId = eventId
    }

    var hasLoaded: Bool { wall != nil }

    /// The entries to show: types this app doesn't know are left out.
    var entries: [WallEntry] { wall?.entries.filter(\.isKnown) ?? [] }

    /// Whether the composer's Post button is enabled.
    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isPosting
    }

    /// Loads the newest page. (Older pages: follow `nextCursor`, not built yet.)
    func load(from repository: any EventsRepository) async {
        do {
            wall = try await repository.wall(eventId: eventId, page: .first)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func post(using repository: any EventsRepository) async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isPosting = true
        defer { isPosting = false }
        do {
            let entry = try await repository.postToWall(eventId: eventId, text: text)
            wall?.entries.insert(entry, at: 0)
            draft = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ entry: WallEntry, using repository: any EventsRepository) async {
        do {
            try await repository.deleteWallEntry(id: entry.id, eventId: eventId)
            wall?.entries.removeAll { $0.id == entry.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
