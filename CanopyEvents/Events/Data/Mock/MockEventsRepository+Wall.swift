import Foundation

/// The activity wall. Hosts can delete any post; authors their own.
extension MockEventsRepository {
    func wallPosts(eventId: Event.ID) async throws -> [WallPost] {
        await pause()
        let record = try record(eventId)
        return posts
            .filter { $0.eventId == eventId }
            .sorted { $0.createdAt > $1.createdAt }
            .map { post in
                var post = post
                post.canDelete = record.isHost(currentUser.id) || (post.kind == .post && post.author?.id == currentUser.id)
                return post
            }
    }

    func addWallPost(eventId: Event.ID, body: String) async throws -> WallPost {
        await pause()
        _ = try record(eventId)
        let post = WallPost(id: UUID().uuidString, eventId: eventId, kind: .post, author: currentUser.person,
                            body: body, createdAt: .now, canDelete: true)
        posts.append(post)
        return post
    }

    func deleteWallPost(id: WallPost.ID, eventId: Event.ID) async throws {
        await pause()
        posts.removeAll { $0.id == id && $0.eventId == eventId }
    }

    /// An automatic entry such as "Maya C is going" or "Time changed".
    func addAutomaticPost(eventId: Event.ID, kind: WallPostKind, body: String) {
        posts.append(WallPost(id: UUID().uuidString, eventId: eventId, kind: kind, author: currentUser.person,
                              body: body, createdAt: .now, canDelete: false))
    }
}
