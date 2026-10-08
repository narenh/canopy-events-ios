import Foundation

/// A list put on an event (`PUT /events/{id}/lists/{listId}`): which, and
/// when. It invites in its owner's name.
struct MockAttachedList: Hashable {
    var listId: String
    var attachedAt: Date
}
