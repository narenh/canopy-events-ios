import Foundation

/// The editor's time zone lists, as the web's `nearbyZones` and
/// `allZones` make them.
nonisolated enum TimeZoneChoices {
    /// Within three hours of yours.
    static let nearbySeconds = 3 * 60 * 60

    /// The menu's first list: the zones within three hours of `viewer` at
    /// `date` (the event's start, so summer time is right for that day),
    /// one per offset, west to east. Each offset is stood for by the first
    /// main zone with it, preferring your own part of the world. Your zone
    /// and the event's (`selected`) are always there, as their own lines
    /// unless a main zone has the same name. From Pacific: Hawaii, Alaska,
    /// Pacific, Mountain, Central, Eastern.
    static func nearby(viewer: TimeZone, at date: Date, selected: TimeZone?) -> [TimeZoneChoice] {
        let namer = TimeZoneName(at: date)
        let mine = viewer.secondsFromGMT(for: date)
        let region = regionOf(viewer.identifier)
        var byOffset: [Int: (id: String, rank: Int)] = [:]
        for (index, id) in TimeZoneName.mainZones.enumerated() {
            guard let zone = TimeZone(identifier: id) else { continue }
            let offset = zone.secondsFromGMT(for: date)
            guard abs(offset - mine) <= nearbySeconds else { continue }
            let rank = (regionOf(id) == region ? 0 : 1000) + index
            if let held = byOffset[offset], held.rank <= rank { continue }
            byOffset[offset] = (id, rank)
        }
        var list = byOffset.map { (id: $0.value.id, offset: $0.key, rank: $0.value.rank) }
        for zone in [viewer, selected].compactMap({ $0 }) {
            let name = namer.name(zone)
            guard !list.contains(where: { TimeZone(identifier: $0.id).map(namer.name) == name }) else { continue }
            let main = TimeZoneName.mainZones.firstIndex(of: zone.identifier) ?? 999
            list.append((zone.identifier, zone.secondsFromGMT(for: date), main))
        }
        let yours = namer.name(viewer)
        let chosen = selected.map(namer.name)
        return list
            .sorted { ($0.offset, $0.rank) < ($1.offset, $1.rank) }
            .compactMap { item in
                guard let zone = TimeZone(identifier: item.id) else { return nil }
                let name = namer.name(zone)
                return TimeZoneChoice(identifier: item.id, name: name, city: TimeZoneName.city(zone), offset: item.offset,
                                      isYours: name == yours, isSelected: name == chosen)
            }
    }

    /// Every zone, for the search: west to east, then by name and city.
    static func all(at date: Date) -> [TimeZoneChoice] {
        let namer = TimeZoneName(at: date)
        return Set(TimeZone.knownTimeZoneIdentifiers).compactMap { id -> TimeZoneChoice? in
            guard let zone = TimeZone(identifier: id) else { return nil }
            return TimeZoneChoice(identifier: id, name: namer.name(zone), city: TimeZoneName.city(zone),
                                  offset: zone.secondsFromGMT(for: date))
        }
        .sorted { ($0.offset, $0.name, $0.city) < ($1.offset, $1.name, $1.city) }
    }

    private static func regionOf(_ id: String) -> Substring {
        id.split(separator: "/").first ?? Substring(id)
    }
}
