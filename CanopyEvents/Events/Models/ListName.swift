/// A list as its link shows it to anyone: only its name (the API's
/// `ListLink.list`).
nonisolated struct ListName: Codable, Hashable {
    var name: String
}
