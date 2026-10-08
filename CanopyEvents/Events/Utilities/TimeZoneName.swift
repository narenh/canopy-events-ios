import Foundation

/// Time zones by friendly name, as the web names them (`UI.zoneName`):
/// the generic name ("Pacific Time", with "Standard Time" shortened to
/// "Time"), overridden where that's clumsy or wrong ("Hawaii Time",
/// "Arizona", "London"...). A zone that shares a main zone's generic name
/// but not its clock (Mexico City is "Central" with no summer time) goes
/// by its city, as does one with no name. The API still stores IANA ids.
nonisolated struct TimeZoneName {
    /// The zones the menu offers first, west to east. When two read the
    /// same at a moment, the one listed first stands for that offset.
    static let mainZones = [
        "Pacific/Honolulu", "America/Anchorage", "America/Los_Angeles", "America/Denver", "America/Phoenix",
        "America/Chicago", "America/Mexico_City", "America/New_York", "America/Halifax", "America/St_Johns",
        "America/Sao_Paulo", "America/Argentina/Buenos_Aires", "Europe/London", "Africa/Lagos", "Europe/Paris",
        "Africa/Johannesburg", "Europe/Athens", "Europe/Moscow", "Africa/Nairobi", "Asia/Jerusalem", "Asia/Dubai",
        "Asia/Karachi", "Asia/Kolkata", "Asia/Bangkok", "Asia/Shanghai", "Asia/Singapore", "Asia/Tokyo", "Asia/Seoul",
        "Australia/Perth", "Australia/Adelaide", "Australia/Brisbane", "Australia/Sydney", "Pacific/Auckland",
    ]

    static let overrides = [
        "Pacific/Honolulu": "Hawaii Time", "America/Phoenix": "Arizona", "America/Mexico_City": "Mexico City",
        "America/Sao_Paulo": "Brasília Time", "America/Argentina/Buenos_Aires": "Argentina Time",
        "America/Buenos_Aires": "Argentina Time", "Europe/London": "London", "Africa/Johannesburg": "South Africa Time",
        "Europe/Moscow": "Moscow Time", "Asia/Dubai": "Gulf Time", "Asia/Karachi": "Pakistan Time",
        "Asia/Kolkata": "India Time", "Asia/Calcutta": "India Time", "Asia/Shanghai": "China Time",
        "Asia/Singapore": "Singapore Time", "Asia/Tokyo": "Japan Time", "Asia/Seoul": "Korea Time",
        "Australia/Perth": "Western Australia Time", "Australia/Adelaide": "Central Australia Time",
        "Australia/Brisbane": "Brisbane", "Australia/Sydney": "Eastern Australia Time", "UTC": "UTC", "Etc/UTC": "UTC",
    ]

    /// When (the generic name's season; it rarely matters).
    let date: Date
    /// Who owns each generic name among the main zones: "Central Time"
    /// is Chicago's. Worked out once per namer, since lists ask often.
    private let mainByName: [String: String]

    init(at date: Date = .now) {
        self.date = date
        var owners: [String: String] = [:]
        for id in Self.mainZones {
            guard let zone = TimeZone(identifier: id), let name = Self.genericName(zone) else { continue }
            if owners[name] == nil { owners[name] = id }
        }
        mainByName = owners
    }

    /// "Pacific Time", "Arizona", "Mexico City".
    func name(_ zone: TimeZone) -> String {
        if let name = Self.overrides[zone.identifier] { return name }
        if let generic = Self.genericName(zone) {
            guard let owner = mainByName[generic], owner != zone.identifier else { return generic }
            if let main = TimeZone(identifier: owner), sameRules(main, zone) { return name(main) }
        }
        return Self.city(zone)
    }

    /// One-off: a zone's friendly name now.
    static func friendly(_ zone: TimeZone, at date: Date = .now) -> String {
        TimeZoneName(at: date).name(zone)
    }

    /// "PDT", at that date: for list rows, where the line is tight.
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

    /// The system's generic English name, or nil when it has only "GMT-5".
    private static func genericName(_ zone: TimeZone) -> String? {
        guard let name = zone.localizedName(for: .generic, locale: Locale(identifier: "en_US")),
              name.range(of: #"^(GMT|UTC)([+\-−]|$)"#, options: .regularExpression) == nil
        else { return nil }
        return name.hasSuffix(" Standard Time") ? String(name.dropLast(" Standard Time".count)) + " Time" : name
    }

    /// The same clock all year: the same offset in January and July.
    private func sameRules(_ a: TimeZone, _ b: TimeZone) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let year = calendar.component(.year, from: date)
        return [1, 7].allSatisfy { month in
            let at = calendar.date(from: DateComponents(year: year, month: month, day: 15)) ?? date
            return a.secondsFromGMT(for: at) == b.secondsFromGMT(for: at)
        }
    }
}
