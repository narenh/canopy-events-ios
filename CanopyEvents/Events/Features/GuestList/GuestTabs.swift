import Foundation

/// The guests sheet's tabs and what's under them, as plain values (the
/// web's `guestTabsOf`, `guestTabCount` and `guestResults`): a tab for each
/// status there's anyone in, in order Going, Maybe, Invited, Can't Go,
/// Waitlist and (hosts) Removed; the chosen tab's count and plus-ones and
/// its people; or, while searching, everyone whose name matches. It only
/// ever has what the guest list gave this viewer, so it can't show more.
nonisolated struct GuestTabs {
    static let order: [RSVPStatus] = [.going, .maybe, .invited, .notGoing, .waitlisted, .removed]

    /// As `GET /events/{id}/guests` gave them (every page).
    var guests: [Guest]
    /// `?status=removed`, for hosts; empty for anyone else.
    var removed: [Guest]
    var counts: RSVPCounts
    var isHost: Bool
    var query = ""

    /// How many in a tab: the event's count where it has one, else the rows.
    func count(_ status: RSVPStatus) -> Int {
        if status == .removed { return removed.count }
        let rows = guests.count(where: { $0.status == status })
        return max(status == .invited ? counts.invited ?? 0 : counts.count(for: status), rows)
    }

    /// The tabs there's anyone in. Invited and Removed are for hosts only.
    var tabs: [RSVPStatus] {
        Self.order.filter { status in
            (isHost || (status != .invited && status != .removed)) && count(status) > 0
        }
    }

    /// The tab showing: the one chosen if it's still there, else the first.
    func shown(_ chosen: RSVPStatus?) -> RSVPStatus? {
        chosen.flatMap { tabs.contains($0) ? $0 : nil } ?? tabs.first
    }

    func rows(in status: RSVPStatus) -> [Guest] {
        status == .removed ? removed : guests.filter { $0.status == status }
    }

    var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Everyone whose name matches, across every tab (the removed for hosts).
    var matches: [Guest] {
        (guests + (isHost ? removed : [])).filter { NameSearch.matches($0.person, query) }
    }

    /// A tab's name: "Going", "Can't Go", "Waitlist"...
    static func title(_ status: RSVPStatus) -> String {
        status == .waitlisted ? "Waitlist" : status.title
    }

    /// Under the tabs: "3 Going · +2 guests".
    func summary(_ status: RSVPStatus) -> String {
        let plusOnes = switch status {
        case .going: counts.guests.going
        case .maybe: counts.guests.maybe
        case .waitlisted: counts.guests.waitlisted
        default: 0
        }
        let words = "\(count(status)) \(Self.title(status))"
        return plusOnes == 0 ? words : words + " · " + (plusOnes == 1 ? "+1 guest" : "+\(plusOnes) guests")
    }
}
