import Foundation

/// A failure from the events API, in the API's own error shape:
/// `{"error": "<a sentence>", "reason": "<snake_case_code>"}`.
/// Branch on `reason`; show `message` to people.
nonisolated struct APIError: Error, Codable, Hashable, LocalizedError {
    var message: String
    var reason: String

    var errorDescription: String? { message }

    enum CodingKeys: String, CodingKey {
        case message = "error"
        case reason
    }
}

extension APIError {
    static let eventNotFound = APIError(message: "There's no event at that link.", reason: "event_not_found")
    static let eventCancelled = APIError(message: "This event has been cancelled.", reason: "event_cancelled")
    static let eventOver = APIError(message: "This event is over.", reason: "event_over")
    static let hostCannotRSVP = APIError(message: "Hosts don't RSVP to their own event.", reason: "host_cannot_rsvp")
    static let hostsOnly = APIError(message: "Only hosts can do that.", reason: "hosts_only")
    static let tooManyGuests = APIError(message: "That's more plus-ones than the host allows.", reason: "too_many_guests")
    static let emailUnverified = APIError(message: "Verify your email first.", reason: "email_unverified")
}
