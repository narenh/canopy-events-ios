import Foundation

/// One size of an event's cover, a JPEG (the API's `CoverImage`). An
/// event lists every size it has, narrowest first; `CoverSize` picks one.
nonisolated struct CoverImage: Codable, Hashable {
    /// In pixels.
    var width: Int
    /// In pixels, so a frame can be sized before the image loads.
    var height: Int
    /// Public, and changes with every upload.
    var url: URL
}
