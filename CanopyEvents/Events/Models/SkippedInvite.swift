/// Someone an invite didn't go to, with the API's reason:
/// `already_on_list`, `is_host` or `not_found`.
nonisolated struct SkippedInvite: Codable, Hashable {
    var personId: Person.ID
    var reason: String
}
