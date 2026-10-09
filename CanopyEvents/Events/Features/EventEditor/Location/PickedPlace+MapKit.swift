import MapKit

extension PickedPlace {
    /// A suggestion, resolved. The name is the item's for a named place
    /// and the suggestion's title (the street line) for an address; the
    /// address is iOS 26's `addressRepresentations` on one line with the
    /// country (as the web's has it), else `address.fullAddress`'s lines
    /// joined with ", ", with runs of spaces folded (Apple writes "CA  94110");
    /// the pin to 6 decimals; the id is `identifier?.rawValue`.
    init(item: MKMapItem, suggestion: PlaceSuggestion) {
        let coordinate = item.location.coordinate
        let lines = item.address.map { $0.fullAddress.split(whereSeparator: \.isNewline).joined(separator: ", ") }
        self.init(
            name: suggestion.kind == .poi ? item.name ?? suggestion.title : suggestion.title,
            address: (item.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true) ?? lines)
                .map { $0.split(separator: " ").joined(separator: " ") },
            latitude: Self.rounded(coordinate.latitude),
            longitude: Self.rounded(coordinate.longitude),
            applePlaceId: item.identifier?.rawValue,
            kind: suggestion.kind
        )
    }

    /// To 6 decimals (about 10 cm), as the server keeps them.
    static func rounded(_ degrees: Double) -> Double {
        (degrees * 1_000_000).rounded() / 1_000_000
    }
}
