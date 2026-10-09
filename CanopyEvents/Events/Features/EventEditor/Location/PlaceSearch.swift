/// Where the Location field's suggestions come from, and how a picked
/// one becomes a place: Apple Maps on the device (`MapKitPlaceSearch`),
/// or a fake that drives `LocationFieldModel` in tests.
protocol PlaceSearch: AnyObject {
    /// Called with the suggestions for a query whenever new ones arrive
    /// (the query they answer first, so stale ones can be dropped).
    var onSuggestions: ((_ query: String, _ suggestions: [PlaceSuggestion]) -> Void)? { get set }
    /// The field got focus: the time to find where the device is, so
    /// suggestions lean there (the real one asks for location the first
    /// time). Never waited for.
    func prepare()
    /// Asks for suggestions for `query`; they come through `onSuggestions`.
    func suggest(_ query: String)
    /// Stops asking (the list closed).
    func cancel()
    /// The whole place a suggestion stands for.
    func place(for suggestion: PlaceSuggestion) async throws -> PickedPlace
}
