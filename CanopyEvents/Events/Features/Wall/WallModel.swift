import Foundation
import Observation

/// An event's activity wall: loading posts, writing one, deleting one.
@Observable
final class WallModel {
    let eventId: Event.ID
    private(set) var posts: [WallPost] = []
    private(set) var hasLoaded = false
    private(set) var isPosting = false
    /// What's typed in the composer.
    var draft = ""
    var errorMessage: String?

    init(eventId: Event.ID) {
        self.eventId = eventId
    }

    var canPost: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isPosting
    }

    func load(from repository: any EventsRepository) async {
        do {
            posts = try await repository.wallPosts(eventId: eventId)
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func post(using repository: any EventsRepository) async {
        let body = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return }
        isPosting = true
        defer { isPosting = false }
        do {
            let post = try await repository.addWallPost(eventId: eventId, body: body)
            posts.insert(post, at: 0)
            draft = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ post: WallPost, using repository: any EventsRepository) async {
        do {
            try await repository.deleteWallPost(id: post.id, eventId: eventId)
            posts.removeAll { $0.id == post.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
