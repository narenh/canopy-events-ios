import CoreGraphics
import Foundation
import ImageIO

nonisolated extension CGImage {
    /// The image as PNG file data.
    var pngData: Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, self, nil)
        return CGImageDestinationFinalize(destination) ? data as Data : nil
    }
}
