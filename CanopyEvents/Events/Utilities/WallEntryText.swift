import Foundation

/// Words the server's own wall entries, which arrive typed rather than
/// written out: "Ana L is going", "Ana L moved it to Sat, Oct 11, 8 PM".
enum WallEntryText {
    /// The sentence for an automatic entry; nil for a post (show its
    /// `text`) or a type the app doesn't know (show nothing).
    static func string(for entry: WallEntry) -> String? {
        let name = entry.person?.shortName ?? "Someone"
        switch entry.type {
        case .post, .unknown:
            return nil
        case .going:
            return "\(name) is going"
        case .offWaitlist:
            return "\(name) got a spot"
        case .timeChanged:
            guard let start = entry.details?.startsAt else { return "\(name) changed the time" }
            let zone = entry.details?.timeZone.flatMap(TimeZone.init(identifier:)) ?? .current
            let when = EventDateFormatter.short(start, in: zone)
            return "\(name) moved it to \(when)"
        case .placeChanged:
            guard let place = entry.details?.locationName ?? entry.details?.locationAddress else {
                return "\(name) changed the place"
            }
            return "\(name) moved it to \(place)"
        case .cancelled:
            return "\(name) cancelled the event"
        case .uncancelled:
            return "It's back on"
        case .cohostAdded:
            return "\(name) is co-hosting"
        }
    }

    /// An SF Symbol for an automatic entry.
    static func systemImage(for type: WallEntryType) -> String {
        switch type {
        case .going, .offWaitlist: "checkmark.circle"
        case .timeChanged: "clock"
        case .placeChanged: "mappin.circle"
        case .cancelled: "xmark.octagon"
        case .uncancelled: "arrow.uturn.backward.circle"
        case .cohostAdded: "star.circle"
        case .post, .unknown: "text.bubble"
        }
    }
}
