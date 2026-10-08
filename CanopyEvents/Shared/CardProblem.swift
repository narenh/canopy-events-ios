/// Why a notification's card couldn't be read, for the extension's log.
nonisolated enum CardProblem: Error, CustomStringConvertible, Sendable {
    /// No `card` key; the keys there were.
    case missing(keys: [String])
    /// Something under `card` that isn't a JSON object.
    case notJSON(type: String)
    /// JSON, but not a card.
    case undecodable(String)

    var description: String {
        switch self {
        case .missing(let keys): "no card in userInfo (keys: \(keys.joined(separator: ", ")))"
        case .notJSON(let type): "card isn't JSON (\(type))"
        case .undecodable(let error): "card won't decode: \(error)"
        }
    }
}
