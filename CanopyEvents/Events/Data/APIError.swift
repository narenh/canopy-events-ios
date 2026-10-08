import Foundation

/// A failure from the events API or the account service, in their shared
/// error shape: `{"error": "<a sentence>", "reason": "<snake_case_code>"}`,
/// sometimes with a link or two. Branch on `reason`; show `message` to people.
nonisolated struct APIError: Error, Codable, Hashable, LocalizedError {
    var message: String
    var reason: APIErrorReason
    /// With `sign_in_required`: where to sign in and come back.
    var signIn: URL?
    /// With `sign_in_required`: the quick sign-up, for someone new to Canopy.
    var quickSignUp: URL?
    /// With `email_unverified` about your own email: where to prove it.
    /// Missing when it's about someone you tried to make a co-host.
    var verify: URL?
    /// The account service's `email_has_account`: the email that has one.
    var email: String?

    var errorDescription: String? { message }

    enum CodingKeys: String, CodingKey {
        case message = "error"
        case reason, signIn, quickSignUp, verify, email
    }
}
