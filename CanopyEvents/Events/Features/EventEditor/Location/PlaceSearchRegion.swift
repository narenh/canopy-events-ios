import CoreLocation
import MapKit

/// Where the Location field's suggestions lean: about 50 km around the
/// device once its location is known, else around San Francisco (the
/// server's default). It asks for location (when in use, approximate is
/// enough) once, the first time the field gets focus (`find()`); typing
/// never waits for it, and a denial is never asked again.
final class PlaceSearchRegion {
    static let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    /// What the completers lean towards now.
    private(set) var region: MKCoordinateRegion
    /// Called when a location arrives and `region` moves to it.
    var onChange: ((MKCoordinateRegion) -> Void)?
    /// The device's location, asking if need be; nil when denied or off.
    private let locate: () async -> CLLocationCoordinate2D?
    private var asked = false

    /// Starts around `lastKnown` (the device's last location, when the
    /// app may already use it), else San Francisco.
    init(lastKnown: CLLocationCoordinate2D? = PlaceSearchRegion.lastKnown(),
         locate: @escaping () async -> CLLocationCoordinate2D? = PlaceSearchRegion.deviceLocation) {
        region = Self.around(lastKnown ?? Self.sanFrancisco)
        self.locate = locate
    }

    /// About 50 km across, a bias (not a limit) for the completers.
    static func around(_ center: CLLocationCoordinate2D) -> MKCoordinateRegion {
        MKCoordinateRegion(center: center, latitudinalMeters: 50_000, longitudinalMeters: 50_000)
    }

    /// The field got focus: where the device is, asked once. A location
    /// moves the region there; none (denied, restricted, off) leaves it.
    func find() async {
        guard !asked else { return }
        asked = true
        guard let center = await locate() else { return }
        region = Self.around(center)
        onChange?(region)
    }

    /// The device's last known location, only if the app may already use
    /// it (any "authorized": when in use, always; the Mac has only always).
    static func lastKnown() -> CLLocationCoordinate2D? {
        let manager = CLLocationManager()
        let allowed = ![.notDetermined, .restricted, .denied].contains(manager.authorizationStatus)
        return allowed ? manager.location?.coordinate : nil
    }

    /// The device's location: a when-in-use session (the system asks the
    /// first time; after a denial it doesn't), then the first location
    /// from live updates, approximate or not. nil once it's denied or
    /// restricted. The Mac has no `CLServiceSession`: it asks the
    /// `CLLocationManager` way.
    static func deviceLocation() async -> CLLocationCoordinate2D? {
        let manager = CLLocationManager()
        let status = manager.authorizationStatus
        guard status != .denied, status != .restricted else { return nil }
        #if os(macOS)
        if status == .notDetermined { manager.requestWhenInUseAuthorization() }
        defer { withExtendedLifetime(manager) {} }
        #else
        let session = CLServiceSession(authorization: .whenInUse)
        defer { session.invalidate() }
        #endif
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if let location = update.location { return location.coordinate }
                if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted {
                    return nil
                }
            }
        } catch {}
        return nil
    }
}
