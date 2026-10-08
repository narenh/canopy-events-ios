/// The answer to inviting people: who was invited, and who wasn't and why.
nonisolated struct InviteResult: Codable, Hashable {
    var invited: [Person]
    var skipped: [SkippedInvite]
}
