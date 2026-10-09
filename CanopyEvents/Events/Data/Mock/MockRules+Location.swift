import Foundation

/// The server's location rules (canopy-events lib/eventInput.js
/// `cleanCoordinates` and lib/views.js), for the mock.
extension MockRules {
    /// A location as the server keeps it: trimmed text, empty as none;
    /// the pin both or neither (`bad_coordinates`), in range, to 6
    /// decimals; a place id in the API's form (`bad_apple_place_id`); no
    /// pin or id without a name or address (`bad_coordinates`); and a name
    /// that is the address's first line dropped, since that's the street
    /// address, which mustn't be public. Mock drafts are whole, so the
    /// pin is always sent with the place (no "left out, so cleared").
    static func stored(_ location: EventLocation) throws -> EventLocation {
        var kept = EventLocation(locationName: trimmed(location.locationName), locationAddress: trimmed(location.locationAddress))
        switch (location.latitude, location.longitude) {
        case (nil, nil):
            break
        case let (latitude?, longitude?) where (-90...90).contains(latitude) && (-180...180).contains(longitude):
            kept.latitude = PickedPlace.rounded(latitude)
            kept.longitude = PickedPlace.rounded(longitude)
        default:
            throw APIError.badCoordinates
        }
        if let id = location.applePlaceId, !id.isEmpty {
            guard EventLocation.validPlaceId(id) != nil else { throw APIError.badApplePlaceId }
            kept.applePlaceId = id
        }
        if kept.locationName == nil && kept.locationAddress == nil && (kept.hasPin || kept.applePlaceId != nil) {
            throw APIError.badCoordinates
        }
        if let name = kept.locationName, let address = kept.locationAddress, firstLine(name) == firstLine(address) {
            kept.locationName = nil
        }
        return kept
    }

    /// The signed-out view of where (and for someone a host removed): the
    /// name only. No address, pin or place id, and `locationAddressHidden`
    /// when there was an address or a pin.
    static func hideLocation(of event: inout Event) {
        event.locationAddressHidden = event.locationAddress != nil || event.latitude != nil || event.applePlaceId != nil
        event.locationAddress = nil
        event.latitude = nil
        event.longitude = nil
        event.applePlaceId = nil
    }

    /// An address's first line ("1 Market St" of "1 Market St, San
    /// Francisco"), lowercased with its spaces folded, to compare a name with.
    static func firstLine(_ text: String) -> String {
        text.prefix { $0 != "," && !$0.isNewline }
            .lowercased()
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private static func trimmed(_ text: String?) -> String? {
        let text = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? nil : text
    }
}
