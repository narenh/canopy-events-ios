/// What a wall entry is (the API's `WallEntry.type`). Posts are written by
/// people; the rest are the server's own, typed rather than written out,
/// for the app to word (see `WallEntryText`).
///
/// The server will add types: any it doesn't know decodes as `unknown`,
/// and the app shows nothing for those.
nonisolated enum WallEntryType: String, Codable, Hashable {
    /// A post, in `text`, by `person`.
    case post
    /// `person` said they're going.
    case going
    /// `person` got a spot from the waitlist.
    case offWaitlist = "off_waitlist"
    /// A host (`person`) moved it; the new times are in `details`.
    case timeChanged = "time_changed"
    /// A host (`person`) changed where; the new place is in `details`.
    case placeChanged = "place_changed"
    /// A host (`person`) cancelled it.
    case cancelled
    /// A host (`person`) took the cancel back.
    case uncancelled
    /// `person` was made a co-host.
    case cohostAdded = "cohost_added"
    /// A type this version of the app doesn't know.
    case unknown

    init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: raw) ?? .unknown
    }
}
