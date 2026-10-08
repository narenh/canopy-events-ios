import Foundation

/// The body of `GET /api/v1/me` (the API's `MeEnvelope`): you, where to
/// verify your email while it's unverified (`verifyUrl` is nil after),
/// and whether to show the Hosting tab.
nonisolated struct MeEnvelope: Codable, Hashable {
    var person: Me
    var verifyUrl: URL?
    /// Whether you host or co-host any event, cancelled and past ones
    /// included. A co-host who stepped down from their only event is back
    /// to false.
    var hasHosted: Bool
}
