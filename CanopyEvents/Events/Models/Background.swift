import Foundation

/// One of the curated film and TV backdrops (from TMDB) a host can make
/// an event's cover instead of uploading a photo (the API's
/// `Background`). Chosen, it becomes an ordinary cover.
nonisolated struct Background: Codable, Hashable, Identifiable, Sendable {
    /// Opaque: send back the one the list gave.
    var id: String
    var title: String
    var year: Int?
    /// 300 px wide, from TMDB's public image CDN, for the grid.
    var thumbUrl: URL
    /// 780 px wide, as the hero while the host decides.
    var previewUrl: URL
    /// The thumbnail's size (its shape: 16:9 or close).
    var width: Int
    var height: Int
    /// The hue that matches it (0–359), or nil when `grayscale`.
    var hue: Int?
    var grayscale: Bool

    /// The color that matches it, for the editor's slider.
    var theme: EventTheme { grayscale ? .grayscale : hue.map { .hue($0) } ?? .grayscale }
}
