/// A suggestion, resolved (an `MKMapItem` in the app): what's needed to
/// save it. Shaped like the API's `Place`, with the pin as `latitude` and
/// `longitude`. Plain values, so turning it into an event's fields is
/// tested without MapKit.
nonisolated struct PickedPlace: Hashable {
    /// The place's name; for a street address, its street line.
    var name: String
    /// The whole address on one line, when known.
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var applePlaceId: String?
    var kind: PlaceKind
}
