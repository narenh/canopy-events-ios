import SwiftUI

/// The type scale, following the web's (events.css): body at 17 pt like
/// iOS, nothing a person reads under 15 pt, and event titles big and
/// heavy. Every style is a Dynamic Type style, so accessibility sizes
/// still scale; weights are what make it the web's.
enum Typography {
    /// An event's title at the top of its page (the web's 32–36 px, 800).
    static let eventTitle = Font.system(.largeTitle, weight: .heavy)
    /// The day and date right under it (24–26 px, 600)...
    static let whenDate = Font.system(.title2, weight: .semibold)
    /// ...and the time, nearly as big (21–23 px, 500).
    static let whenTime = Font.system(.title3, weight: .medium)
    /// Every event-page card's heading, one size for all ("RSVP",
    /// "Hosting", "Attending", "Updates"; the web's 22 px, 800).
    static let sectionTitle = Font.system(.title2, weight: .heavy)
    /// A card's heading, e.g. "Are you going?" (19 px, 700).
    static let cardHeading = Font.system(.title3, weight: .bold)
    /// An event's title in a list (19–20 px, 700).
    static let listTitle = Font.system(.title3, weight: .bold)
    /// The bold accent line above a list title: "SAT, OCT 10 · 7:30 PM".
    static let listWhen = Font.system(.subheadline, weight: .heavy)
    /// Small capitals in a pill ("NEXT FRIDAY", "CANCELLED").
    static let tag = Font.system(.footnote, weight: .bold)
    /// Buttons (17 px, 700).
    static let button = Font.system(.body, weight: .bold)
    /// Small labels above sections in lists.
    static let sectionLabel = Font.system(.subheadline, weight: .bold)
}
