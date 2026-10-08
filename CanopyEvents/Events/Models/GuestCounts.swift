/// Plus-ones, or people and plus-ones together, for the answers that
/// bring anyone (the API's `GuestCounts`). See `RSVPCounts`.
nonisolated struct GuestCounts: Codable, Hashable {
    var going = 0
    var maybe = 0
    var waitlisted = 0
}
