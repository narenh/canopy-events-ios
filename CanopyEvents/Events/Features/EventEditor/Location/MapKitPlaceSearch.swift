import MapKit

/// Apple Maps' suggestions and places, asked on the device (no server):
/// two `MKLocalSearchCompleter`s, one asked only for points of interest
/// and one only for addresses, so each suggestion's kind is what Apple
/// was asked for rather than a guess from its words; then, for a pick,
/// an `MKLocalSearch` with its completion. Both lean towards
/// `PlaceSearchRegion.current()`.
final class MapKitPlaceSearch: NSObject, PlaceSearch, MKLocalSearchCompleterDelegate {
    var onSuggestions: ((String, [PlaceSuggestion]) -> Void)?
    private let places = MKLocalSearchCompleter()
    private let addresses = MKLocalSearchCompleter()
    private let region: MKCoordinateRegion
    /// The completions behind the suggestions shown, to resolve a pick.
    private var completions: [PlaceSuggestion.ID: MKLocalSearchCompletion] = [:]

    init(region: MKCoordinateRegion = PlaceSearchRegion.current()) {
        self.region = region
        super.init()
        places.resultTypes = .pointOfInterest
        addresses.resultTypes = .address
        for completer in [places, addresses] {
            completer.region = region
            completer.delegate = self
        }
    }

    func suggest(_ query: String) {
        places.queryFragment = query
        addresses.queryFragment = query
    }

    func cancel() {
        places.cancel()
        addresses.cancel()
    }

    func place(for suggestion: PlaceSuggestion) async throws -> PickedPlace {
        guard let completion = completions[suggestion.id] else { throw MKError(.placemarkNotFound) }
        let request = MKLocalSearch.Request(completion: completion)
        request.resultTypes = suggestion.kind == .poi ? .pointOfInterest : .address
        request.region = region
        let response = try await MKLocalSearch(request: request).start()
        guard let item = response.mapItems.first else { throw MKError(.placemarkNotFound) }
        return PickedPlace(item: item, suggestion: suggestion)
    }

    // MARK: MKLocalSearchCompleterDelegate

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        publish()
    }

    /// No network, or nothing found: whatever each still has (often none).
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        publish()
    }

    /// Both completers' latest, merged (`PlaceSuggestion.merged`).
    private func publish() {
        let query = places.queryFragment
        let pois = suggestions(from: places, kind: .poi)
        let streets = suggestions(from: addresses, kind: .address)
        onSuggestions?(query, PlaceSuggestion.merged(places: pois, addresses: streets, for: query))
    }

    private func suggestions(from completer: MKLocalSearchCompleter, kind: PlaceKind) -> [PlaceSuggestion] {
        completer.results.map { completion in
            let suggestion = PlaceSuggestion(
                id: "\(kind.rawValue)\n\(completion.title)\n\(completion.subtitle)",
                title: completion.title, subtitle: completion.subtitle, kind: kind
            )
            completions[suggestion.id] = completion
            return suggestion
        }
    }
}
