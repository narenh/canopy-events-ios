import SwiftUI

/// The few custom text styles. Everything else uses the system's Dynamic
/// Type styles (`.body`, `.headline`, ...) directly.
enum Typography {
    /// The big title over an event's cover image.
    static let heroTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    /// An event's title in a card or row.
    static let cardTitle = Font.system(.headline, design: .rounded, weight: .semibold)
    /// Small capitalised labels above sections.
    static let sectionLabel = Font.system(.footnote, weight: .semibold)
}
