import Foundation

/// Friendly time zone names, as the web shows them: "Pacific Time",
/// "Central European Time", with the short form ("PDT") where it helps.
/// The API still stores IANA ids.
nonisolated enum TimeZoneName {
    /// "Pacific Time" (the generic name, the same summer and winter).
    static func friendly(_ zone: TimeZone, locale: Locale = .current) -> String {
        zone.localizedName(for: .generic, locale: locale)
            ?? zone.identifier.split(separator: "/").last.map { $0.replacingOccurrences(of: "_", with: " ") }
            ?? zone.identifier
    }

    /// "PDT", at that date.
    static func abbreviation(_ zone: TimeZone, at date: Date) -> String {
        zone.abbreviation(for: date) ?? zone.identifier
    }

    /// "Los Angeles", from the id.
    static func city(_ zone: TimeZone) -> String {
        zone.identifier.split(separator: "/").last.map { $0.replacingOccurrences(of: "_", with: " ") } ?? zone.identifier
    }

    /// Whether someone in `viewer` reads the event's times the same: the
    /// same wall clock at that moment (Phoenix and Los Angeles in summer).
    static func sameClock(_ zone: TimeZone, _ viewer: TimeZone, at date: Date) -> Bool {
        zone.identifier == viewer.identifier || zone.secondsFromGMT(for: date) == viewer.secondsFromGMT(for: date)
    }
}
