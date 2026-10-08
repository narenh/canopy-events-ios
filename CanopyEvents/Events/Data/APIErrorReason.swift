/// An error's `reason`: the snake_case code to branch on. A struct rather
/// than an enum because the servers add codes over time, and an unknown
/// one must still decode. The codes are in `APIErrorReason+Events` and
/// `APIErrorReason+Accounts`; compare with `==`, e.g.
/// `error.reason == .noRoom`.
nonisolated struct APIErrorReason: RawRepresentable, Codable, Hashable, Sendable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
