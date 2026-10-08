/// Someone an invite didn't go to, and why.
nonisolated struct SkippedInvite: Codable, Hashable {
    var personId: Person.ID
    var reason: SkippedInviteReason
}
