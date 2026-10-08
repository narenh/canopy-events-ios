import Foundation

/// The body of `GET /api/v1/me`: you, plus where to verify your email
/// while it's unverified (`verifyUrl` is null after).
nonisolated struct MeEnvelope: Codable, Hashable {
    var person: Me
    var verifyUrl: URL?
    /// Whether you've ever hosted or co-hosted an event, past or cancelled
    /// included. Turns on the Hosting tab, for good. Not in the API spec
    /// yet (see ARCHITECTURE.md, "Mock vs real").
    var hasHosted: Bool
}
