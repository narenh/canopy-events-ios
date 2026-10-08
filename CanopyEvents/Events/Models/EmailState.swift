/// The account service's answer to the right sign-in code
/// (`POST /auth/email/verify`, its `EmailState`): the email is proven for
/// 15 minutes, and `state` says what's next.
nonisolated struct EmailState: Codable, Hashable {
    /// Always true here.
    var verified: Bool
    var state: EmailAccountState
    /// The address as cleaned (lowercase).
    var email: String
    /// `existing` only.
    var firstName: String?
    /// `existing` only: whether the account has any passkey.
    var hasPasskey: Bool?
    /// `existing` only. True means the account's email was never proven
    /// (a quick sign-up): finishing takes it over, removing its other
    /// passkeys and signing out its other phones. Say so first.
    var unverified: Bool?
}
