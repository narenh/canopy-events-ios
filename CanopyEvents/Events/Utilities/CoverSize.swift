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
        guard let first = images.first else { return fallback }
        let photoAspect = CGFloat(first.width) / CGFloat(max(first.height, 1))
        let needed = frameWidth * scale * max(1, photoAspect / frameAspect)
        return (images.first { CGFloat($0.width) >= needed } ?? images.last)?.url
    }
}
