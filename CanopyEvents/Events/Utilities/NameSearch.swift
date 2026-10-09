import Foundation

/// Searching people by name, accents and case aside: "ines" finds "Inés"
/// (the web's `foldName`). The pickers, a list's people and the guests
/// sheet all search this way.
nonisolated enum NameSearch {
    /// Letters without their accents, in lower case.
    static func fold(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US"))
    }

    /// Whether `person`'s full name has what's typed in it; nothing typed
    /// matches everyone.
    static func matches(_ person: Person, _ typed: String) -> Bool {
        let needle = fold(typed.trimmingCharacters(in: .whitespaces))
        return needle.isEmpty || fold(person.fullName).contains(needle)
    }
}
