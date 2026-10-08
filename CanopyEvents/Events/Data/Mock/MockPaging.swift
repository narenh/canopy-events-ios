/// Pages a whole list the way the server does, so the mock answers with
/// real `nextCursor`s. The mock's cursor is just an offset; the real one
/// is opaque.
enum MockPaging {
    static let defaultLimit = 20

    static func page<Item>(_ items: [Item], _ request: PageRequest) throws -> (items: [Item], nextCursor: String?) {
        let limit = request.limit ?? defaultLimit
        guard (1...100).contains(limit) else {
            throw APIError(message: "A page is 1 to 100.", reason: .badLimit)
        }
        guard let start = request.cursor.map({ Int($0) }) ?? 0, (0...items.count).contains(start) else {
            throw APIError(message: "That cursor isn't one of ours. Start again.", reason: .badCursor)
        }
        let end = min(start + limit, items.count)
        return (Array(items[start..<end]), end < items.count ? String(end) : nil)
    }
}
