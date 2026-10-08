/// What a proven email leads to at sign-in: a new account to make, or an
/// existing one to add this phone's passkey to.
nonisolated enum EmailAccountState: String, Codable, Hashable {
    case new
    case existing
}
