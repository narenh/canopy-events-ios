import Foundation

/// The facts behind a `time_changed` or `place_changed` wall entry (the
/// API's `WallEntry.details`, null for every other type). The spec has two
/// shapes; this holds either, and the entry's `type` says which is filled:
/// `startsAt`, `endsAt` (nil for no end) and `timeZone` for a time change,
/// `locationName` and `locationAddress` for a place change.
nonisolated struct WallEntryDetails: Codable, Hashable {
    var startsAt: Date?
    var endsAt: Date?
    var timeZone: String?
    var locationName: String?
    var locationAddress: String?
}
