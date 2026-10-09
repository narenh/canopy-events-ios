@testable import CanopyEvents

/// Apple Maps, faked, to drive `LocationFieldModel`: records what it was
/// asked, answers when told to, and resolves a pick to `places[id]`
/// (or fails without one) once `resolve` lets it.
final class FakePlaceSearch: PlaceSearch {
    var onSuggestions: ((String, [PlaceSuggestion]) -> Void)?
    private(set) var asked: [String] = []
    private(set) var cancels = 0
    var places: [PlaceSuggestion.ID: PickedPlace] = [:]
    /// Held picks, resumed by `resolve()`.
    private var waiting: [CheckedContinuation<Void, Never>] = []
    var holdsPicks = false

    func suggest(_ query: String) { asked.append(query) }
    func cancel() { cancels += 1 }

    /// Apple answers `query` with `suggestions`.
    func answer(_ query: String, _ suggestions: [PlaceSuggestion]) {
        onSuggestions?(query, suggestions)
    }

    func place(for suggestion: PlaceSuggestion) async throws -> PickedPlace {
        if holdsPicks { await withCheckedContinuation { waiting.append($0) } }
        guard let place = places[suggestion.id] else { throw CancellationError() }
        return place
    }

    /// Lets held picks finish.
    func resolve() {
        waiting.forEach { $0.resume() }
        waiting = []
    }
}
