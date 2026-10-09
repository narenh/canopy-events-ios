import Foundation

/// Where an event is: the API's five location fields together, as an
/// event has them and as the editor sends them (docs/api.md, "Where: the
/// location"). `locationName` is public (link previews too); the address,
/// the pin and `applePlaceId` are for signed-in guests only.
nonisolated struct EventLocation: Hashable {
    /// A named place ("Dolores Park"), never a street address.
    var locationName: String?
    /// The address, or a place typed by hand: private.
    var locationAddress: String?
    /// With `longitude`, always: both or neither.
    var latitude: Double?
    var longitude: Double?
    /// Apple Maps' id for the place (`MKMapItem.identifier?.rawValue`).
    var applePlaceId: String?

    var hasPin: Bool { latitude != nil && longitude != nil }
}

nonisolated extension EventLocation {
    /// Typed text (`Use "…"`, or just left typed): the address only, with
    /// no name, pin or place id, so it's private. It may well be someone's
    /// home, and only a pick from the map says a place is one anyone may
    /// know about. The web's `locationFromText`.
    static func typed(_ text: String) -> EventLocation {
        let words = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return EventLocation(locationAddress: words.isEmpty ? nil : words)
    }
}
