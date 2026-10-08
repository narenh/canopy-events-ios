import SwiftUI

/// Canopy's colors: a rainforest canopy at night. Carried over from the
/// account service's `account.css`, where each was contrast-checked
/// against glass cards over the brightest glow.
///
/// The accent (#2EC44F) lives in Assets as `AccentColor`, so system
/// controls pick it up on their own; use `Color.accentColor` for it.
enum Palette {
    /// The near-black page background, #03120C.
    static let base = Color(red: 0x03 / 255, green: 0x12 / 255, blue: 0x0C / 255)
    /// The mesh's glows, darkest to brightest.
    static let glowDeep = Color(red: 0x07 / 255, green: 0x2B / 255, blue: 0x1F / 255)
    static let glowSoft = Color(red: 0x0A / 255, green: 0x3B / 255, blue: 0x2E / 255)
    static let glow = Color(red: 0x0F / 255, green: 0x4A / 255, blue: 0x33 / 255)
    static let glowBright = Color(red: 0x14 / 255, green: 0x5C / 255, blue: 0x3E / 255)
    /// Links and highlighted text on dark green, #B6F5C3.
    static let link = Color(red: 0xB6 / 255, green: 0xF5 / 255, blue: 0xC3 / 255)
    /// Secondary text that still reads on glass, #E2ECE4.
    static let muted = Color(red: 0xE2 / 255, green: 0xEC / 255, blue: 0xE4 / 255)
    /// Text and icons placed on the accent, #03190A.
    static let onAccent = Color(red: 0x03 / 255, green: 0x19 / 255, blue: 0x0A / 255)
    /// The accent, #2EC44F, for where the asset catalog's `AccentColor`
    /// isn't there (the notification extension).
    static let accent = Color(red: 0x2E / 255, green: 0xC4 / 255, blue: 0x4F / 255)
    /// Errors and destructive hints, #FFD2CA.
    static let danger = Color(red: 0xFF / 255, green: 0xD2 / 255, blue: 0xCA / 255)
}
