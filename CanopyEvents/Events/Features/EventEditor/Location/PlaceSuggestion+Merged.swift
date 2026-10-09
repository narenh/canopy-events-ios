nonisolated extension PlaceSuggestion {
    /// The most suggestions shown (the web's 8).
    static let shown = 8

    /// Places and addresses as one list: addresses first when the text
    /// starts with a digit (a house number), else places first; the first
    /// kind keeps at least 5 rows when the other has more; repeats (the
    /// same title and subtitle) are left out.
    static func merged(places: [PlaceSuggestion], addresses: [PlaceSuggestion], for query: String) -> [PlaceSuggestion] {
        let (first, second) = query.first?.isNumber == true ? (addresses, places) : (places, addresses)
        var seen = Set<String>()
        let unique: ([PlaceSuggestion]) -> [PlaceSuggestion] = { list in
            list.filter { seen.insert($0.title + "\n" + $0.subtitle).inserted }
        }
        let firsts = unique(first)
        let seconds = unique(second)
        let firstCount = min(firsts.count, max(5, shown - seconds.count))
        return Array((firsts.prefix(firstCount) + seconds).prefix(shown))
    }
}
