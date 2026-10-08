/// Proof of who's signed in. For real, a `canopy_session` value (43
/// characters, base64url) from the account service's native sign-in,
/// sent to the events API as `Authorization: Bearer <value>`. In the
/// mock it's just the person's id.
nonisolated struct AuthToken: Hashable {
    var value: String
}
