import CoreGraphics
import Foundation
import ImageIO

/// Where the mock keeps an uploaded cover: a file in the temporary
/// folder, which `AsyncImage` loads like any URL. Gone when the app is.
enum MockCoverFile {
    static func save(_ data: Data) -> URL? {
        let url = URL.temporaryDirectory.appending(path: "cover-\(UUID().uuidString)")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    /// The photo's width and height in pixels, upright; nil if it isn't one.
    static func pixelSize(of data: Data) -> (width: Int, height: Int)? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int
        else { return nil }
        // Orientations 5–8 are turned a quarter: width and height swap.
        let orientation = properties[kCGImagePropertyOrientation] as? Int ?? 1
        return orientation >= 5 ? (height, width) : (width, height)
    }
}
