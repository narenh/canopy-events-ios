import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// A link drawn as a QR code the way docs/api.md asks: the text exactly
/// the URL (its UTF-8 bytes), correction level M, four modules of white
/// round it, one pixel a module (draw it scaled up with no smoothing).
nonisolated enum QRCode {
    static func image(for text: String) -> CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"
        guard let code = filter.outputImage else { return nil }
        // The filter leaves one module of white; three more make four.
        let frame = code.extent.insetBy(dx: -3, dy: -3)
        let tile = code.composited(over: CIImage(color: .white).cropped(to: frame))
        return CIContext().createCGImage(tile, from: frame)
    }
}
