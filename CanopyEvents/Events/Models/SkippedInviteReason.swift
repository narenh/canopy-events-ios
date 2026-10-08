/// Why an invite didn't go to someone (the API's `InviteResult.skipped[].reason`).
nonisolated enum SkippedInviteReason: String, Codable, Hashable {
    /// Invited before, or already answered.
    case alreadyOnList = "already_on_list"
    case isHost = "is_host"
    /// No such account.
    case notFound = "not_found"
    /// A host removed them from the event.
    case removed
}
