/// A seed event's place on the map: its pin and Apple Maps' id, as a
/// pick from Apple's suggestions would have saved them. The ids are made
/// up (the spec's example's form), so Maps can't look them up.
struct MockPin {
    var latitude: Double
    var longitude: Double
    var applePlaceId: String?

    static let doloresPark = MockPin(latitude: 37.759773, longitude: -122.427063, applePlaceId: "I5B8A0D4E1F2C3B7A")
    static let hydeStreetPier = MockPin(latitude: 37.806587, longitude: -122.42149, applePlaceId: "I7C2E9A41B0D3F6A8")
}
