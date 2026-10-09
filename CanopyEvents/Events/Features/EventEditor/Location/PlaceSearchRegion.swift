import CoreLocation
import MapKit

/// Where the Location field's suggestions lean: around the device when
/// the app may already use its location, else around San Francisco (the
/// server's default). It never asks for permission: a prompt just to
/// type a place is too much (the web's call too).
enum PlaceSearchRegion {
    static let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    /// About 50 km across, a bias (not a limit) for the completers.
    static func current() -> MKCoordinateRegion {
        let manager = CLLocationManager()
        // Any "authorized" (when in use, always; the Mac has only always).
        let allowed = ![.notDetermined, .restricted, .denied].contains(manager.authorizationStatus)
        let center = (allowed ? manager.location?.coordinate : nil) ?? sanFrancisco
        return MKCoordinateRegion(center: center, latitudinalMeters: 50_000, longitudinalMeters: 50_000)
    }
}
