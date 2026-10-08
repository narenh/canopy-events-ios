import Foundation

/// Small helpers for showing people's names. The server already sends
/// `shortName` ("Ana L"); these cover the cases where the app has only a
/// first and last name, like the quick sign-up form or avatar initials.
enum PersonName {
    /// "Ana L" from "Ana" and "Lima".
    static func short(firstName: String, lastName: String) -> String {
        guard let initial = lastName.trimmingCharacters(in: .whitespaces).first else {
            return firstName
        }
        return "\(firstName) \(initial)"
    }

    /// "AL" from "Ana" and "Lima", for avatar placeholders.
    static func initials(firstName: String, lastName: String) -> String {
        let letters = [firstName.first, lastName.first].compactMap { $0 }
        return String(letters).uppercased()
    }
}
