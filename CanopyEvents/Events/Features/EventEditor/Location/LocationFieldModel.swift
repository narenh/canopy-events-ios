import Foundation
import Observation

/// The editor's Location field (the web's, in views/editor.html): one box
/// for a place or an address. From 2 characters it suggests places: Use
/// "<typed>" first, always, then Apple Maps'. Picking one of Apple's shows
/// its name in the field and its address muted under it, and resolves it
/// for the pin; typing again lets the pick go. Typed text saves as the
/// address only, private. Untouched, it saves what the event had.
@Observable
final class LocationFieldModel {
    enum Mode {
        /// As the event had it: saves exactly that.
        case kept
        /// Typed by hand: saves as `EventLocation.typed`.
        case typed
        /// Picked from Apple's suggestions.
        case picked
    }

    private(set) var mode = Mode.kept
    /// What's in the field: a pick's name, or what was typed.
    private(set) var text: String
    /// The muted line under the field: a pick's address.
    private(set) var line: String
    /// Apple's suggestions for what's typed. The last ones stay until the
    /// next arrive, so the list doesn't flicker between keys.
    private(set) var suggestions: [PlaceSuggestion] = []
    /// What a kept or picked location saves.
    private var saved: EventLocation
    private var picks = 0
    @ObservationIgnored private let search: any PlaceSearch

    /// Starts as the event has it (the web's `locationStart`): a place
    /// with an address reads as a pick (the name, the address under it);
    /// an address alone, or a name alone, is the field's text.
    init(location: EventLocation, search: any PlaceSearch) {
        let name = location.locationName ?? "", address = location.locationAddress ?? ""
        let both = !name.isEmpty && !address.isEmpty
        text = both || address.isEmpty ? name : address
        line = both ? address : ""
        saved = location
        self.search = search
        search.onSuggestions = { [weak self] query, results in self?.received(results, for: query) }
    }

    /// What's typed, trimmed: what suggestions are asked for.
    var query: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// What the field saves.
    var value: EventLocation { mode == .typed ? .typed(text) : saved }

    /// Whether the list shows (while the field has focus): only for typed
    /// text of 2 characters or more.
    var offersSuggestions: Bool { mode == .typed && query.count >= 2 }

    /// The host typed: a pick (or what the event had) is let go, and
    /// suggestions are asked for.
    func edit(_ newText: String) {
        guard newText != text else { return }
        text = newText
        if mode != .typed {
            mode = .typed
            saved = EventLocation()
            line = ""
        }
        if query.count < 2 {
            suggestions = []
            search.cancel()
        } else {
            search.suggest(query)
        }
    }

    /// The list closed (Use "…", Return, or the field let go): what's
    /// typed stays as typed.
    func close() {
        search.cancel()
    }

    /// One of Apple's suggestions: shown at once, saved as what's known
    /// so far (the name and address, no pin), then as the whole place
    /// once it's found. A failed lookup keeps what's known.
    func pick(_ suggestion: PlaceSuggestion) async {
        search.cancel()
        picks += 1
        let pick = picks
        mode = .picked
        text = suggestion.title
        line = suggestion.subtitle
        let address = suggestion.kind == .address
            ? [suggestion.title, suggestion.subtitle].filter { !$0.isEmpty }.joined(separator: ", ")
            : suggestion.subtitle
        saved = EventLocation(place: PickedPlace(name: suggestion.title, address: address, kind: suggestion.kind))
        guard let place = try? await search.place(for: suggestion), pick == picks, mode == .picked else { return }
        saved = EventLocation(place: place)
        if let address = place.address, !address.isEmpty { line = address }
    }

    /// The ×: an empty field, saving no location.
    func clear() {
        mode = .typed
        text = ""
        line = ""
        saved = EventLocation()
        suggestions = []
        search.cancel()
    }

    private func received(_ results: [PlaceSuggestion], for query: String) {
        guard mode == .typed, query == self.query else { return }
        suggestions = results
    }
}
