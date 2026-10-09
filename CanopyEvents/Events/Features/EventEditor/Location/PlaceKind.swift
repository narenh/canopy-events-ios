/// What a suggestion or pick is (the API's `Place.kind`): a named place,
/// whose name is public, or a street address, which never is.
nonisolated enum PlaceKind: String, Hashable {
    /// A point of interest: a bar, a park. SF Symbol `mappin`.
    case poi
    /// A street address. SF Symbol `house`.
    case address

    var symbol: String { self == .poi ? "mappin" : "house" }
}
