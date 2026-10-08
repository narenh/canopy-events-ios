import Foundation

/// One line of the editor's time zone menu or search.
nonisolated struct TimeZoneChoice: Hashable, Identifiable {
    /// The IANA id, what's saved.
    var identifier: String
    /// "Pacific Time".
    var name: String
    /// "Los Angeles", for the search list.
    var city: String
    /// Seconds ahead of UTC at the event's date.
    var offset: Int
    /// Your own zone (by name): "Your time zone".
    var isYours = false
    /// The event's zone now (by name): ✓.
    var isSelected = false

    var id: String { identifier }

    /// "GMT−7", "GMT+5:30", "GMT".
    var offsetWords: String {
        let minutes = offset / 60
        guard minutes != 0 else { return "GMT" }
        let hours = abs(minutes) / 60
        let rest = abs(minutes) % 60
        return "GMT" + (minutes < 0 ? "−" : "+") + "\(hours)" + (rest > 0 ? String(format: ":%02d", rest) : "")
    }
}
