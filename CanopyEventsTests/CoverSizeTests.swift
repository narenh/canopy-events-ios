import Foundation
import Testing
@testable import CanopyEvents

/// Picking a cover size the way docs/api.md says.
struct CoverSizeTests {
    private func sizes(aspect: Double) -> [CoverImage] {
        [400, 800, 1200, 1600].map { width in
            CoverImage(width: width, height: Int(Double(width) / aspect),
                       url: URL(string: "https://example.com/\(width).jpg")!)
        }
    }

    private func width(_ url: URL?) -> String? { url?.deletingPathExtension().lastPathComponent }

    @Test func heroOnAPhoneTakesThe1200() {
        let url = CoverSize.url(in: sizes(aspect: 4 / 3), fallback: nil, frameWidth: 375, scale: 3)
        #expect(width(url) == "1200")
    }

    @Test func thumbnailTakesThe400() {
        #expect(width(CoverSize.url(in: sizes(aspect: 3 / 2), fallback: nil, frameWidth: 116, scale: 3)) == "400")
    }

    @Test func aWidePhotoIsDrawnWiderThanItsFrame() {
        // 16:9 in a 3:2 frame is drawn 1.19× wider: 116 × 3 × 1.19 = 414 > 400.
        #expect(width(CoverSize.url(in: sizes(aspect: 16 / 9), fallback: nil, frameWidth: 116, scale: 3)) == "800")
    }

    @Test func tooWideForAnyTakesTheBiggestAndNoSizesTakeTheFallback() {
        #expect(width(CoverSize.url(in: sizes(aspect: 3 / 2), fallback: nil, frameWidth: 1000, scale: 2)) == "1600")
        let fallback = URL(string: "https://example.com/full.jpg")
        #expect(CoverSize.url(in: [], fallback: fallback, frameWidth: 375, scale: 3) == fallback)
    }
}
