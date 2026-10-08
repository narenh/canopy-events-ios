import Foundation

/// Finding someone to invite by phone or Instagram, matched exactly
/// against accounts that let themselves be found.
extension MockEventsRepository {
    func lookUpPerson(_ lookup: PersonLookup) async throws -> Person? {
        await pause()
        guard currentUser.emailVerified else { throw APIError.emailUnverified }
        let findable = backend.accounts.filter { $0.findable != false }
        switch lookup {
        case .phone(let typed):
            let phone = try Self.cleanPhone(typed)
            return findable.first { $0.phone == phone }?.person
        case .instagram(let typed):
            let handle = typed.trimmingCharacters(in: .whitespaces).lowercased()
                .trimmingCharacters(in: CharacterSet(charactersIn: "@"))
            guard !handle.isEmpty else { throw APIError(message: "That isn't an Instagram handle.", reason: .badInstagram) }
            return findable.first { $0.instagram == handle }?.person
        }
    }

    /// To E.164 the way the profile does: US and Canadian numbers may leave off the +1.
    private static func cleanPhone(_ typed: String) throws -> String {
        let digits = typed.filter(\.isNumber)
        if typed.trimmingCharacters(in: .whitespaces).hasPrefix("+"), digits.count >= 8 { return "+" + digits }
        if digits.count == 10 { return "+1" + digits }
        if digits.count == 11, digits.hasPrefix("1") { return "+" + digits }
        throw APIError(message: "That isn't a phone number.", reason: .badPhone)
    }
}
