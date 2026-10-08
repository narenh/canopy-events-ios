import Foundation

/// What a search box's text is for the people lookup, the web's
/// `lookupKindOf`: an `@username`, a whole phone number (10 to 15 digits,
/// with the usual `+ ( ) - .` and spaces), or neither (a name, which is
/// never looked up: the lookup is tightly limited).
nonisolated enum LookupKind: Hashable {
    case phone
    case instagram

    init?(_ text: String) {
        let text = text.trimmingCharacters(in: .whitespaces)
        if text.wholeMatch(of: /@[A-Za-z0-9._]{1,30}/) != nil {
            self = .instagram
        } else if text.wholeMatch(of: /\+?[0-9\s().\-]+/) != nil, (10...15).contains(text.count(where: \.isASCIIDigit)) {
            self = .phone
        } else {
            return nil
        }
    }

    /// The lookup to send, as typed.
    func lookup(_ text: String) -> PersonLookup {
        let text = text.trimmingCharacters(in: .whitespaces)
        return self == .phone ? .phone(text) : .instagram(text)
    }
}

private extension Character {
    nonisolated var isASCIIDigit: Bool { isASCII && isNumber }
}
