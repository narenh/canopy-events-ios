import Foundation

/// One entry on an event's activity wall. Not in the API spec yet;
/// the shape is our best guess (see ARCHITECTURE.md).
nonisolated struct WallPost: Codable, Hashable, Identifiable {
    var id: String
    var eventId: Event.ID
    var kind: WallPostKind
    /// Who wrote it, or whom an automatic entry is about.
    var author: Person?
    var body: String
    var createdAt: Date
    /// Hosts can delete any post; authors can delete their own.
    var canDelete: Bool
}
