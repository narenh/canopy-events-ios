import Foundation
import Testing
@testable import CanopyEvents

/// The Location field's pure rules, against the web's `locationFromPlace`,
/// `locationFromText` and docs/api.md: what a pick and typed text save,
/// and how Apple's two kinds of suggestion are merged. Not in a target
/// yet, like `MockFlowTests`.
struct LocationTests {
    private let dolores = PickedPlace(
        name: "Dolores Park", address: "19th St & Dolores St, San Francisco, CA 94114, United States",
        latitude: 37.759773, longitude: -122.427063, applePlaceId: "I5B8A0D4E1F2C3B7A", kind: .poi)

    @Test func aNamedPlaceSavesItsNameAddressPinAndId() {
        #expect(EventLocation(place: dolores) == EventLocation(
            locationName: "Dolores Park", locationAddress: "19th St & Dolores St, San Francisco, CA 94114, United States",
            latitude: 37.759773, longitude: -122.427063, applePlaceId: "I5B8A0D4E1F2C3B7A"))
    }

    @Test func aStreetAddressIsNeverTheName() {
        var street = PickedPlace(name: "1 Dolores St", address: "1 Dolores St, San Francisco, CA 94103, United States",
                                 latitude: 37.7689, longitude: -122.4265, kind: .address)
        let saved = EventLocation(place: street)
        #expect(saved.locationName == nil && saved.locationAddress == street.address && saved.hasPin)
        // No address known: the street line is the address, still not the name.
        street.address = ""
        #expect(EventLocation(place: street).locationAddress == "1 Dolores St")
        #expect(EventLocation(place: street).locationName == nil)
    }

    @Test func halfAPinOrABadIdIsLeftOut() {
        var place = dolores
        place.longitude = nil
        place.applePlaceId = "not an id!"
        let saved = EventLocation(place: place)
        #expect(saved.latitude == nil && saved.longitude == nil && saved.applePlaceId == nil)
        #expect(saved.locationName == "Dolores Park")
    }

    @Test func typedTextIsPrivate() {
        let typed = EventLocation.typed("  Ana's,  12 Oak St\napt 3 ")
        #expect(typed == EventLocation(locationAddress: "Ana's, 12 Oak St apt 3"))
        #expect(typed.locationName == nil && !typed.hasPin && typed.applePlaceId == nil)
        #expect(EventLocation.typed("   ") == EventLocation())
    }

    @Test func placesComeFirstUnlessAHouseNumberIsTyped() {
        let pois = (1...7).map { PlaceSuggestion(id: "p\($0)", title: "Place \($0)", subtitle: "SF", kind: .poi) }
        let streets = (1...4).map { PlaceSuggestion(id: "a\($0)", title: "\($0) Main St", subtitle: "SF", kind: .address) }
        let named = PlaceSuggestion.merged(places: pois, addresses: streets, for: "pla")
        #expect(named.map(\.id) == ["p1", "p2", "p3", "p4", "p5", "a1", "a2", "a3"])
        let numbered = PlaceSuggestion.merged(places: pois, addresses: streets, for: "1 main")
        #expect(numbered.map(\.id) == ["a1", "a2", "a3", "a4", "p1", "p2", "p3", "p4"])
        // Fewer of the second kind: the first fills the rest; repeats go.
        let again = PlaceSuggestion(id: "a9", title: "Place 1", subtitle: "SF", kind: .address)
        #expect(PlaceSuggestion.merged(places: pois, addresses: [again], for: "pla").map(\.id) == pois.map(\.id))
    }

    @Test func aPickedSuggestionsKindPicksItsSymbol() {
        #expect(PlaceKind.poi.symbol == "mappin" && PlaceKind.address.symbol == "house")
    }
}
