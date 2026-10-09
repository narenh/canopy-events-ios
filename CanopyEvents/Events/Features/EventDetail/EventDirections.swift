import MapKit

/// Directions to an event with a pin, in Apple Maps: an `MKMapItem` at
/// the pin, named as the page names the place, opened with directions
/// (the system's default way of getting there). Nil without a pin (only
/// people who see the address get one).
enum EventDirections {
    static func mapItem(for event: Event) -> MKMapItem? {
        guard let latitude = event.latitude, let longitude = event.longitude else { return nil }
        let address = event.locationAddress.flatMap { MKAddress(fullAddress: $0, shortAddress: nil) }
        let item = MKMapItem(location: CLLocation(latitude: latitude, longitude: longitude), address: address)
        item.name = event.locationName ?? event.locationAddress
        return item
    }

    static func open(_ event: Event) {
        mapItem(for: event)?.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
}
