import Foundation
import Testing
@testable import CanopyEvents

/// The app's event colors against the web's, to the byte. The expected
/// values come from canopy-events' `public/ui.js` (`themeColors`,
/// `turnHex`, `coverArt`, `hueFromPixels`), run in node; if the web's
/// maths changes, regenerate them there.
struct ThemeColorTests {
    private func bytes(_ c: RGB) -> [Int] { [c.red, c.green, c.blue] }
    private func all(_ t: ThemeColors) -> [[Int]] {
        [t.base, t.glow1, t.glow2, t.glow3, t.glow4, t.glow5, t.card].map(bytes)
    }

    @Test(arguments: [
        (0, [[24, 9, 12], [93, 45, 60], [74, 37, 43], [115, 56, 76], [55, 26, 33], [73, 35, 47], [43, 14, 29]]),
        (60, [[22, 12, 3], [89, 53, 17], [68, 44, 14], [112, 65, 22], [51, 31, 8], [70, 41, 13], [44, 16, 2]]),
        (90, [[18, 14, 2], [76, 61, 5], [57, 50, 12], [96, 75, 2], [43, 36, 5], [60, 48, 6], [37, 22, 0]]),
        (193, [[1, 18, 19], [0, 73, 72], [0, 58, 62], [0, 90, 89], [0, 42, 44], [0, 57, 57], [0, 31, 27]]),
        (240, [[5, 15, 25], [20, 67, 97], [26, 52, 77], [21, 83, 120], [15, 38, 57], [17, 52, 76], [0, 29, 41]]),
        (300, [[17, 11, 23], [69, 53, 94], [59, 42, 71], [85, 66, 118], [41, 30, 54], [54, 41, 74], [25, 20, 48]]),
        (359, [[24, 9, 13], [92, 45, 61], [74, 37, 44], [115, 56, 77], [55, 26, 33], [73, 35, 47], [43, 14, 30]]),
    ])
    func huesMatchTheWeb(hue: Int, expected: [[Int]]) {
        #expect(all(ThemeColors(.hue(hue))) == expected)
    }

    @Test func greyKeepsTheLightness() {
        let grey = all(ThemeColors(.grayscale))
        #expect(grey == [[14, 14, 14], [62, 62, 62], [50, 50, 50], [78, 78, 78], [36, 36, 36], [49, 49, 49], [25, 25, 25]])
    }

    @Test func canopyGreenIsTheHexAndHue161IsWithinTwo() {
        let green = all(ThemeColors(.canopyGreen))
        #expect(green == [[3, 18, 12], [15, 74, 51], [10, 59, 46], [20, 92, 62], [7, 43, 31], [12, 58, 40], [3, 32, 11]])
        for (a, b) in zip(all(ThemeColors(.hue(161))).joined(), green.joined()) {
            #expect(abs(a - b) <= 2)
        }
    }

    @Test func turningAnyGreen() {
        #expect(bytes(ThemeColors.turn(RGB(hex: "#2ec44f"), to: .hue(300))) == [0x9d, 0x94, 0xff])
        #expect(bytes(ThemeColors.turn(RGB(hex: "#145c3e"), to: .grayscale)) == [0x4e, 0x4e, 0x4e])
        #expect(bytes(ThemeColors.turn(RGB(hex: "#145c3e"), to: .canopyGreen)) == [0x14, 0x5c, 0x3e])
    }

    @Test func outOfGamutColorsLoseChromaNotLightness() {
        let wild = OKLCH.rgb(L: 0.6, C: 0.4, h: 140)
        let (L, _, _) = OKLCH.components(of: wild)
        #expect(abs(L - 0.6) < 0.01)
        #expect(bytes(OKLCH.rgb(L: 1, C: 0, h: 0)) == [255, 255, 255])
        #expect(bytes(OKLCH.rgb(L: 0, C: 0, h: 0)) == [0, 0, 0])
    }

    @Test func coverArtMatchesTheWeb() {
        let art = CoverArtLayout(eventId: "Gm8Night4Fun", theme: .canopyGreen)
        #expect([art.dark, art.wash, art.glow1, art.glow2].map(bytes)
                == [[0x03, 0x12, 0x0c], [0x0f, 0x5a, 0x5a], [0x2e, 0xc4, 0x4f], [0x0a, 0x3b, 0x2e]])
        #expect([art.glow1X, art.glow1Y, art.glow2X, art.glow2Y, art.angle] == [0.13, 0.27, 0.69, 0.40, 207])
        let purple = CoverArtLayout(eventId: "Gm8Night4Fun", theme: .hue(300))
        #expect([purple.dark, purple.wash, purple.glow1, purple.glow2].map(bytes)
                == [[0x11, 0x0b, 0x17], [0x65, 0x40, 0x5e], [0x9d, 0x94, 0xff], [0x3b, 0x2a, 0x47]])
    }

    private func photo(_ pixel: (Int, Int) -> [UInt8]) -> [UInt8] {
        (0..<64).flatMap { y in (0..<64).flatMap { x in pixel(x, y) + [255] } }
    }

    @Test func photoHuesMatchTheWeb() {
        #expect(PhotoHue.hue(ofRGBA: photo { _, _ in [200, 40, 40] }) == 27)
        #expect(PhotoHue.hue(ofRGBA: photo { _, y in y < 40 ? [90, 150, 230] : [60, 160, 60] }) == 257)
        #expect(PhotoHue.hue(ofRGBA: photo { _, _ in [46, 196, 79] }) == 147)
        #expect(PhotoHue.hue(ofRGBA: photo { _, _ in [128, 128, 128] }) == nil)
        #expect(PhotoHue.hue(ofRGBA: photo { x, y in x < 4 && y < 20 ? [220, 30, 30] : [120, 120, 120] }) == nil)
    }

    /// Both sliders, against the web's sliderOf / keyOfSlider /
    /// accentSliderOf / accentOfSlider (SLIDER_GREY 12).
    @Test func theSlidersHaveAShortGreyOrWhiteEndThenTheWheel() {
        #expect(ThemeSliderScale.value(for: .grayscale) == 6)
        #expect(ThemeSliderScale.value(for: .canopyGreen) == 173)
        #expect(ThemeSliderScale.value(for: .hue(10)) == 22)
        #expect(ThemeSliderScale.theme(at: 11) == .grayscale)
        #expect(ThemeSliderScale.theme(at: 12) == .hue(0))
        #expect(ThemeSliderScale.theme(at: 371) == .hue(359))
        #expect(AccentSliderScale.value(for: nil) == 6 && AccentSliderScale.value(for: 10) == 22)
        #expect(AccentSliderScale.accentHue(at: 11) == nil && AccentSliderScale.accentHue(at: 12) == 0)
    }

    /// The accent trio, against the web's `accentColors` (events 1755f46,
    /// public/ui.js `accentTrio`, run in node): each hue's own accent.
    static let webAccents: [(Int, [String])] = [
        (0, ["#ed458a", "#220b13", "#ffd6e1"]),
        (15, ["#f04162", "#230b0d", "#ffd8d9"]),
        (30, ["#f14634", "#240b08", "#ffd9d2"]),
        (45, ["#fe6a00", "#230d04", "#ffdac9"]),
        (60, ["#fc8e00", "#210e01", "#ffdbbf"]),
        (90, ["#e6b700", "#1b1300", "#fbe19a"]),
        (120, ["#afce00", "#111601", "#daeda6"]),
        (161, ["#00e097", "#00190d", "#abf7cf"]),
        (180, ["#00dbc1", "#001914", "#9bf8e5"]),
        (193, ["#00d9d6", "#001818", "#95f7f4"]),
        (220, ["#00d2fe", "#00171f", "#b6edff"]),
        (250, ["#0095fe", "#041526", "#cee6ff"]),
        (270, ["#5c7bff", "#0c1227", "#d8e2ff"]),
        (300, ["#a264f6", "#170f24", "#e7dcff"]),
        (330, ["#e060d8", "#1e0c1d", "#ffd2fa"]),
        (359, ["#ec468c", "#220b13", "#ffd6e2"]),
    ]

    @Test(arguments: 0..<16)
    func eachHueHasItsOwnAccent(row: Int) {
        let (hue, hexes) = Self.webAccents[row]
        let trio = AccentColors(theme: .hue(hue), accentHue: nil)
        #expect([trio.accent, trio.onAccent, trio.text].map(bytes) == hexes.map { bytes(RGB(hex: $0)) })
        #expect(AccentColors(theme: .grayscale, accentHue: hue) == trio)
        #expect(AccentColors.contrast(trio.accent, trio.onAccent) >= 4.99)
    }

    @Test func greenIsUnchangedAndGreyIsWhite() {
        let green = AccentColors(theme: .canopyGreen, accentHue: nil)
        #expect([green.accent, green.onAccent, green.text].map(bytes) == [[0x2e, 0xc4, 0x4f], [0x03, 0x19, 0x0a], [0xb6, 0xf5, 0xc3]])
        let white = AccentColors(theme: .grayscale, accentHue: nil)
        #expect([white.accent, white.onAccent, white.text].map(bytes) == [[255, 255, 255], [14, 14, 14], [255, 255, 255]])
        #expect(white.isWhite && !green.isWhite)
    }
}
