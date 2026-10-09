import CoreLocation
import MapKit
import Testing
@testable import CanopyEvents

/// Where suggestions lean (`PlaceSearchRegion`), with the device's
/// location faked: San Francisco before a location, the device's 50 km
/// after, nothing on a denial, and asking only once. Not in a target
/// yet, like `LocationFieldModelTests`.
@MainActor
struct PlaceSearchRegionTests {
    let oakland = CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2712)

    private func isAround(_ region: MKCoordinateRegion, _ center: CLLocationCoordinate2D) -> Bool {
        let expected = PlaceSearchRegion.around(center)
        return region.center.latitude == center.latitude && region.center.longitude == center.longitude
            && region.span.latitudeDelta == expected.span.latitudeDelta
            && region.span.longitudeDelta == expected.span.longitudeDelta
    }

    @Test func aboutFiftyKilometersAcross() {
        let region = PlaceSearchRegion.around(PlaceSearchRegion.sanFrancisco)
        // A degree of latitude is about 111 km.
        #expect(abs(region.span.latitudeDelta * 111_000 - 50_000) < 1_000)
    }

    @Test func sanFranciscoUntilALocationThenTheDevice() async {
        let fix = HeldLocation()
        let bias = PlaceSearchRegion(lastKnown: nil, locate: fix.locate)
        var moved: [MKCoordinateRegion] = []
        bias.onChange = { moved.append($0) }
        #expect(isAround(bias.region, PlaceSearchRegion.sanFrancisco))
        let finding = Task { await bias.find() }
        await fix.asked()
        // Asked, no answer yet: still San Francisco.
        #expect(isAround(bias.region, PlaceSearchRegion.sanFrancisco) && moved.isEmpty)
        fix.answer(oakland)
        await finding.value
        #expect(isAround(bias.region, oakland))
        #expect(moved.count == 1 && isAround(moved[0], oakland))
    }

    @Test func aDenialLeavesItAndIsNeverAskedAgain() async {
        var asks = 0
        let bias = PlaceSearchRegion(lastKnown: nil) { asks += 1; return nil }
        var moved = 0
        bias.onChange = { _ in moved += 1 }
        await bias.find()
        await bias.find()
        #expect(isAround(bias.region, PlaceSearchRegion.sanFrancisco))
        #expect(moved == 0 && asks == 1)
    }

    @Test func askedOnlyOnceEvenWhenFound() async {
        var asks = 0
        let bias = PlaceSearchRegion(lastKnown: nil) { [oakland] in asks += 1; return oakland }
        await bias.find()
        await bias.find()
        #expect(asks == 1 && isAround(bias.region, oakland))
    }

    @Test func startsAtTheLastKnownLocationWhenAllowed() {
        let bias = PlaceSearchRegion(lastKnown: oakland) { nil }
        #expect(isAround(bias.region, oakland))
    }
}

/// A device location that answers when told to.
@MainActor
private final class HeldLocation {
    private var waiting: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    private var onAsked: CheckedContinuation<Void, Never>?

    func locate() async -> CLLocationCoordinate2D? {
        onAsked?.resume()
        onAsked = nil
        return await withCheckedContinuation { waiting = $0 }
    }

    /// Returns once `locate()` has been called.
    func asked() async {
        guard waiting == nil else { return }
        await withCheckedContinuation { onAsked = $0 }
    }

    func answer(_ location: CLLocationCoordinate2D?) {
        waiting?.resume(returning: location)
        waiting = nil
    }
}
