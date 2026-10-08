import Foundation

/// The line under each name in the invite sheet, in the web's words
/// (public/copy.js, `invite` and `friends.source`).
nonisolated extension InvitePicker {
    /// How a friend is in your list ("Invitation", "Added") when it isn't
    /// events, then the events together: "Invitation, 3 events together".
    /// A friend link isn't words; the row shows it as an icon
    /// (`Candidate.isFriendLink`).
    static func detail(for friend: Friend) -> String {
        let how: String? = switch friend.source {
        case .sharedEvents, .link: nil
        case .added: "Added"
        case .invite: "Invitation"
        }
        let together: String? = switch friend.eventsInCommon {
        case 0: nil
        case 1: "1 event together"
        default: "\(friend.eventsInCommon) events together"
        }
        return [how, together].compactMap(\.self).joined(separator: ", ")
    }

    static func detail(onList name: String) -> String { "On \(name)" }

    static func detail(fromEvent title: String) -> String { "From \(title)" }

    static func detail(foundBy kind: LookupKind) -> String {
        kind == .phone ? "Found by phone number" : "Found by Instagram"
    }

    /// Read out on picking a past event: "Showing 4 from Beach bonfire.",
    /// "No one else from Beach bonfire.", or that its guest list is hidden.
    static func showing(_ from: PastFilter) -> String {
        if from.isHidden { return hidden(from.title) }
        return switch from.ids.count {
        case 0: empty(from.title)
        case 1: "Showing 1 from \(from.title)."
        default: "Showing \(from.ids.count) from \(from.title)."
        }
    }

    static func empty(_ title: String) -> String { "No one else from \(title)." }

    static func hidden(_ title: String) -> String { "\(title)'s guest list isn't shown to you." }

    /// "20 people", "1 person", "No one yet".
    static func count(_ n: Int) -> String {
        switch n {
        case 0: "No one yet"
        case 1: "1 person"
        default: "\(n) people"
        }
    }

    /// After sending: "Invited 7 people." or "Invited 1 person."
    static func invitedNotice(_ n: Int) -> String {
        n == 1 ? "Invited 1 person." : "Invited \(n) people."
    }
}
