nonisolated extension EventLocation {
    /// What a pick is saved as (the web's `locationFromPlace`). A named
    /// place: its name (public) and its address (signed-in guests). A
    /// street address: the address only, never `locationName`, so it's
    /// never public. The pin only as a pair; empty text is none; a place
    /// id only in the form the API takes (`[A-Za-z0-9._:-]{1,128}`).
    init(place: PickedPlace) {
        let name = place.name.isEmpty ? nil : place.name
        let address = place.address.flatMap { $0.isEmpty ? nil : $0 }
        let pinned = place.latitude != nil && place.longitude != nil
        self.init(
            locationName: place.kind == .address ? nil : name,
            locationAddress: address ?? (place.kind == .address ? name : nil),
            latitude: pinned ? place.latitude : nil,
            longitude: pinned ? place.longitude : nil,
            applePlaceId: place.applePlaceId.flatMap(Self.validPlaceId)
        )
    }

    /// `id` if the API would take it as `applePlaceId`, else nil.
    static func validPlaceId(_ id: String) -> String? {
        id.wholeMatch(of: /[A-Za-z0-9._:\-]{1,128}/) == nil ? nil : id
    }
}
