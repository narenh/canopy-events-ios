/// Your settings (`GET`/`PATCH /api/v1/me/settings`, the API's
/// `Settings`), each at its default until changed.
nonisolated struct Settings: Codable, Hashable, Sendable {
    /// Events you're invited to and haven't answered are in your Canopy
    /// calendar ("Show events I'm invited to"). On by default.
    var calendarInvites: Bool
}
