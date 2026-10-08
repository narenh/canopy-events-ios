/// Which page of a list to ask for: the API's `?cursor=&limit=`. Start
/// with `.first`, then pass the answer's `nextCursor` with `.after(_:)`
/// until it's nil. Cursors are opaque: never build or parse one.
nonisolated struct PageRequest: Hashable {
    /// The `nextCursor` of the page before; nil for the first page.
    var cursor: String?
    /// How many to a page, 1 to 100; nil for the server's default (20).
    var limit: Int?

    static let first = PageRequest()

    static func after(_ cursor: String, limit: Int? = nil) -> PageRequest {
        PageRequest(cursor: cursor, limit: limit)
    }
}
