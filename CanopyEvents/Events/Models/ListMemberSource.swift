/// How someone came to be on one of your lists (the API's
/// `ListMembers.members[].source`): `link`, they joined by its link or QR
/// code; `added`, you put them on it.
nonisolated enum ListMemberSource: String, Codable, Hashable {
    case link
    case added
}
