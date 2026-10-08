import Foundation

/// OKLCH ↔ sRGB, the standard maths (Björn Ottosson's OKLab matrices, as
/// in CSS Color 4), ported line for line from the web's `public/ui.js`
/// (`oklchToLinear`, `oklchToRgb`, `rgbToOklch`) so both draw the same
/// bytes. `L` is 0–1, `C` chroma, `h` the hue in degrees.
nonisolated enum OKLCH {
    /// Linear-light sRGB for an OKLCH colour; may fall outside 0–1.
    static func linearSRGB(L: Double, C: Double, h: Double) -> (Double, Double, Double) {
        let a = C * cos(h * .pi / 180)
        let b = C * sin(h * .pi / 180)
        let l = pow(L + 0.3963377774 * a + 0.2158037573 * b, 3)
        let m = pow(L - 0.1055613458 * a - 0.0638541728 * b, 3)
        let s = pow(L - 0.0894841775 * a - 1.2914855480 * b, 3)
        return (
            4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
            -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
            -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
        )
    }

    /// The colour as sRGB bytes. One outside sRGB has its chroma lowered
    /// (L and hue kept) until it fits, as docs/api.md says.
    static func rgb(L: Double, C: Double, h: Double) -> RGB {
        func fits(_ c: Double) -> Bool {
            let (r, g, b) = linearSRGB(L: L, C: c, h: h)
            return [r, g, b].allSatisfy { $0 >= -0.0001 && $0 <= 1.0001 }
        }
        var chroma = C
        if !fits(chroma) {
            var low = 0.0
            var high = C
            for _ in 0..<20 {
                let mid = (low + high) / 2
                if fits(mid) { low = mid } else { high = mid }
            }
            chroma = low
        }
        let (r, g, b) = linearSRGB(L: L, C: chroma, h: h)
        return RGB(byte(r), byte(g), byte(b))
    }

    /// An sRGB colour as (L, C, h), h in 0..<360.
    static func components(of rgb: RGB) -> (L: Double, C: Double, h: Double) {
        let (A, B, L) = lab(linear(rgb.red), linear(rgb.green), linear(rgb.blue))
        let hue = (atan2(B, A) * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
        return (L, hypot(A, B), hue)
    }

    /// OKLab (a, b, L) from linear-light sRGB.
    static func lab(_ r: Double, _ g: Double, _ b: Double) -> (a: Double, b: Double, L: Double) {
        let l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
        let m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
        let s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
        return (
            1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
            0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
            0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
        )
    }

    /// An sRGB byte to linear light.
    static func linear(_ byte: Int) -> Double {
        let c = Double(byte) / 255
        return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    /// Linear light to an sRGB byte (clamped), rounding as JavaScript's
    /// `Math.round` does.
    private static func byte(_ c: Double) -> Int {
        let v = c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1 / 2.4) - 0.055
        return Int((min(1, max(0, v)) * 255 + 0.5).rounded(.down))
    }
}
