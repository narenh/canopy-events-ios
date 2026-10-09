/// A stand-in for Apple Maps in previews: the same few suggestions for
/// anything typed, and each resolves to itself, pinned in San Francisco.
final class PreviewPlaceSearch: PlaceSearch {
    static let samples = [
        PlaceSuggestion(id: "1", title: "Dolores Park", subtitle: "19th St & Dolores St, San Francisco, CA", kind: .poi),
        PlaceSuggestion(id: "2", title: "Dolores Street Baptist Church", subtitle: "938 Valencia St, San Francisco, CA", kind: .poi),
        PlaceSuggestion(id: "3", title: "1 Dolores St", subtitle: "San Francisco, CA, United States", kind: .address),
    ]

    var onSuggestions: ((String, [PlaceSuggestion]) -> Void)?

    func suggest(_ query: String) {
        onSuggestions?(query, Self.samples)
    }

    func cancel() {}

    func place(for suggestion: PlaceSuggestion) async throws -> PickedPlace {
        PickedPlace(name: suggestion.title, address: suggestion.subtitle, latitude: 37.7597, longitude: -122.4271,
                    applePlaceId: nil, kind: suggestion.kind)
    }
}
