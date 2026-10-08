import CoreGraphics
import Foundation

/// Which size of a cover to download, as docs/api.md says: the narrowest
/// at least as wide as it's drawn, in pixels, else the biggest. A photo
/// wider than its frame is cropped (aspect fill), so it's drawn wider
/// than the frame: allow for that too.
nonisolated enum CoverSize {
    /// - Parameters:
    ///   - frameWidth: the frame's width in points.
    ///   - frameAspect: the frame's width ÷ height (3:2 everywhere today).
    ///   - scale: the screen's scale (`displayScale`).
    static func url(
        in images: [CoverImage], fallback: URL?,
        frameWidth: CGFloat, frameAspect: CGFloat = 3 / 2, scale: CGFloat
    ) -> URL? {
        // The photo's shape from its biggest size, the least rounded.
        guard let biggest = images.last else { return fallback }
        let photoAspect = CGFloat(biggest.width) / CGFloat(max(biggest.height, 1))
        let needed = frameWidth * scale * max(1, photoAspect / frameAspect)
        // A pixel of slack: heights are whole pixels (800 × 533 is "3:2").
        return (images.first { CGFloat($0.width) + 1 >= needed } ?? images.last)?.url
    }
}
