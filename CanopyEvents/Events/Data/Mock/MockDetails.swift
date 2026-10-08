import Foundation

/// The server's checks on an event's details (docs/api.md, "Event
/// details"), as the mock applies them: up to 10; a value is required; a
/// link is http or https (one without a scheme gets https) with no user
/// name; a phone is 3 to 20 digits with spaces, dashes, dots, brackets or
/// a leading +; labels up to 60 characters and values up to 500. A
/// refusal says which detail in `index`.
enum MockDetails {
    static func checked(_ inputs: [EventDetailInput]) throws -> [EventDetail] {
        guard inputs.count <= 10 else {
            throw APIError(message: "An event has at most 10 details.", reason: .tooManyDetails)
        }
        return try inputs.enumerated().map { index, input in
            func refuse(_ message: String, _ reason: APIErrorReason) -> APIError {
                APIError(message: message, reason: reason, index: index)
            }
            guard input.type != .unknown else { throw refuse("That isn't a kind of detail.", .badDetailType) }
            let value = input.value.trimmingCharacters(in: .whitespacesAndNewlines)
            let label = input.label?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else { throw refuse("Fill this in, or take it off.", .badDetailValue) }
            guard (label?.count ?? 0) <= 60, value.count <= 500 else { throw refuse("That's too long.", .detailTooLong) }
            let shownLabel = label?.isEmpty == false ? label : nil
            switch input.type {
            case .link:
                guard let url = link(value) else {
                    throw refuse("A link is a web address, starting http:// or https://.", .badDetailURL)
                }
                return EventDetail(type: .link, label: shownLabel, value: url, href: url)
            case .phone:
                let digits = value.filter(\.isNumber)
                let allowed = CharacterSet(charactersIn: "0123456789 -.()+")
                guard (3...20).contains(digits.count), value.unicodeScalars.allSatisfy(allowed.contains),
                      !value.dropFirst().contains("+") else {
                    throw refuse("That isn't a phone number.", .badDetailPhone)
                }
                return EventDetail(type: .phone, label: shownLabel, value: value,
                                   href: "tel:" + (value.hasPrefix("+") ? "+" : "") + digits)
            default:
                return EventDetail(type: input.type, label: shownLabel, value: value, href: nil)
            }
        }
    }

    /// http(s) only; no scheme gets https; no user name.
    private static func link(_ typed: String) -> String? {
        let hasScheme = typed.range(of: "^[a-zA-Z][a-zA-Z0-9+.-]*:", options: .regularExpression) != nil
        let text = hasScheme ? typed : "https://" + typed
        guard let url = URL(string: text), let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
              let host = url.host, host.contains("."), url.user == nil else { return nil }
        return url.absoluteString
    }
}
