/// The backgrounds a host can choose from (`GET /api/v1/backgrounds`), in
/// display order with a title's next to each other. `enabled` false (and
/// none): show no picker.
nonisolated struct BackgroundList: Codable, Hashable {
    var enabled: Bool
    var backgrounds: [Background]

    /// Consecutive entries with the same title and year, as the web groups them.
    var groups: [[Background]] {
        var groups: [[Background]] = []
        for background in backgrounds {
            if let last = groups.last?.last, last.title == background.title, last.year == background.year {
                groups[groups.count - 1].append(background)
            } else {
                groups.append([background])
            }
        }
        return groups
    }
}
