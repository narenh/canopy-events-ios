/// Hosts whose invitations you've opted out of (`GET
/// /api/v1/me/invite-optouts`), oldest first. Only ever shown to you.
nonisolated struct InviteOptouts: Codable, Hashable {
    var hosts: [Person]
}
