/// Who can see the guest list's names, picked by the host per event.
/// Hosts always see everything; counts are always visible.
nonisolated enum GuestListVisibility: String, Codable, Hashable, CaseIterable {
    /// Anyone with the link sees names and photos.
    case everyone
    /// You see names once you've answered (any answer).
    case responded

    var title: String {
        switch self {
        case .everyone: "Everyone"
        case .responded: "After they RSVP"
        }
    }

    var explanation: String {
        switch self {
        case .everyone: "Anyone with the link can see who's coming."
        case .responded: "Guests see who's coming once they've answered."
        }
    }
}
