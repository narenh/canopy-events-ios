/// One of the Location field's suggestions (an `MKLocalSearchCompletion`
/// in the app): its title, a muted subtitle (usually the address or the
/// city), and whether it's a named place or a street address.
nonisolated struct PlaceSuggestion: Hashable, Identifiable {
    /// Unique among one answer's suggestions.
    let id: String
    let title: String
    let subtitle: String
    let kind: PlaceKind
}
