/// One of your lists that was on the event being copied (the spec's
/// inline `DuplicateDraft.lists` item): just enough to offer it again.
nonisolated struct DuplicateDraftList: Codable, Hashable, Identifiable {
    var id: String
    var name: String
}
