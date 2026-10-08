import CoreGraphics
import Foundation
import ImageIO

/// The hue that matches a photo, worked out the way the server does for
/// `coverHue` (docs/api.md, "The colour that matches the photo"; the web's
/// `hueFromPixels`), so the editor's slider can jump to it as soon as a
/// photo is picked. Nil for an essentially grey photo.
nonisolated enum PhotoHue {
    /// The theme that matches a photo's file data (JPEG, PNG, HEIC...),
    /// shrunk to fit 64×64 first: its hue, or grey. Nil if it can't be read.
    static func theme(ofImageData data: Data) -> EventTheme? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                  kCGImageSourceCreateThumbnailFromImageAlways: true,
                  kCGImageSourceCreateThumbnailWithTransform: true,
                  kCGImageSourceThumbnailMaxPixelSize: 64,
              ] as CFDictionary)
        else { return nil }
        let width = image.width
        let height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        return hue(ofRGBA: pixels).map { .hue($0) } ?? .grayscale
    }

    /// From RGBA bytes. Pixels go to OKLCH; near-greys (C < 0.04), very
    /// dark (L < 0.2) and very light (L > 0.93) ones are skipped; the rest
    /// add their chroma to one-degree bins; the best ±12° window wins,
    /// refined to its chroma-weighted circular mean. Under 4% of pixels
    /// counting means grey (nil).
    static func hue(ofRGBA data: [UInt8]) -> Int? {
        var bins = [Double](repeating: 0, count: 360)
        var voters = 0
        let count = data.count / 4
        for i in 0..<count {
            let (a, b, L) = OKLCH.lab(
                OKLCH.linear(Int(data[i * 4])), OKLCH.linear(Int(data[i * 4 + 1])), OKLCH.linear(Int(data[i * 4 + 2]))
            )
            let chroma = hypot(a, b)
            if chroma < 0.04 || L < 0.2 || L > 0.93 { continue }
            let hue = (atan2(b, a) * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
            bins[Int(hue.rounded(.down)) % 360] += chroma
            voters += 1
        }
        guard count > 0, Double(voters) / Double(count) >= 0.04 else { return nil }
        let window = 12
        func bin(_ h: Int) -> Double { bins[(h + 360) % 360] }
        var best = 0
        var bestSum = -1.0
        for h in 0..<360 {
            let sum = (-window...window).reduce(0) { $0 + bin(h + $1) }
            if sum > bestSum {
                bestSum = sum
                best = h
            }
        }
        var x = 0.0
        var y = 0.0
        for d in -window...window {
            let h = (best + d + 360) % 360
            x += bins[h] * cos((Double(h) + 0.5) * .pi / 180)
            y += bins[h] * sin((Double(h) + 0.5) * .pi / 180)
        }
        let mean = (atan2(y, x) * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
        return Int((mean + 0.5).rounded(.down)) % 360
    }
}
