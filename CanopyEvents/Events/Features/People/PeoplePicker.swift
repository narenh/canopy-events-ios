import Foundation

/// The invite sheet's state, without the loading: who the sheet knows,
/// who's on the event already, your lists, and who's picked, in the order
/// picked. The web's `inviteOrder`, `listPickable` and `setPicked`
/// (canopy-events public/ui.js and views/event.html), as plain values so
/// they're testable.
nonisolated struct InvitePicker {
    /// How many suggestions show above everyone else.
    static let suggestedShown = 8

    /// Someone the sheet knows, with the line under their name (a friend
    /// made by friend link has an icon before it).
    struct Candidate: Hashable {
        var person: Person
        var detail: String
        var isFriendLink = false
    }

    /// One of your lists, for "Invite all <n>".
    struct PickList: Hashable, Identifiable {
        var id: OwnedList.ID
        var name: String
        var memberIds: [Person.ID]
    }

    /// "Filter by past event": one of your past events' hosts and going
    /// and maybe guests. Hidden when its guest list isn't shown to you.
    struct PastFilter: Hashable {
        var eventId: Event.ID
        var title: String
        var ids: [Person.ID]
        var isHidden: Bool
    }

    /// Someone's part in the event already.
    enum Status: Hashable {
        case hosting
        case rsvp(RSVPStatus)
    }

    var me: Person.ID?
    private(set) var people: [Person.ID: Candidate] = [:]
    /// Best first, from `GET /me/friends/suggested`.
    var suggestedIds: [Person.ID] = []
    var lists: [PickList] = []
    /// Hosts, everyone invited or answered, and the removed.
    var onEvent: [Person.ID: Status] = [:]
    /// In the order picked.
    private(set) var selected: [Person.ID] = []
    var query = ""
    /// The past event the list is narrowed to; nil for everyone.
    var from: PastFilter?

    /// Adds someone the first time; whoever added them first gives the line.
    mutating func add(_ person: Person, detail: String, isFriendLink: Bool = false) {
        guard person.id != me, people[person.id] == nil else { return }
        people[person.id] = Candidate(person: person, detail: detail, isFriendLink: isFriendLink)
    }

    /// Not on the event yet, and not you.
    func isPickable(_ id: Person.ID) -> Bool {
        onEvent[id] == nil && id != me
    }

    func isPicked(_ id: Person.ID) -> Bool {
        selected.contains(id)
    }

    /// Picks (newest last) or unpicks; anyone not pickable is left alone.
    mutating func setPicked(_ ids: [Person.ID], _ on: Bool) {
        if on {
            for id in ids where isPickable(id) && !selected.contains(id) { selected.append(id) }
        } else {
            selected.removeAll { ids.contains($0) }
        }
    }

    mutating func toggle(_ id: Person.ID) {
        setPicked([id], !isPicked(id))
    }

    /// Takes out anyone who's on the event now (after a send, or a reload).
    mutating func dropUnpickable() {
        let onEvent = onEvent, me = me
        selected.removeAll { onEvent[$0] != nil || $0 == me }
    }

    // MARK: Lists

    /// A list's people who could be picked: the `n` of "Invite all <n>".
    func pickable(in list: PickList) -> [Person.ID] {
        list.memberIds.filter(isPickable)
    }

    /// Every one of them picked: "Invite all" shows as on.
    func isAllPicked(_ list: PickList) -> Bool {
        let ids = pickable(in: list)
        return !ids.isEmpty && ids.allSatisfy(isPicked)
    }

    /// "Invite all <n>" is a toggle: it picks them all, or, when they all
    /// are, unpicks them.
    mutating func toggleAll(in list: PickList) {
        setPicked(pickable(in: list), !isAllPicked(list))
    }

    // MARK: Order

    /// The picked, newest first, for the tray.
    var tray: [Person] {
        selected.reversed().compactMap { people[$0]?.person }
    }

    var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Suggested: the first eight suggestions who aren't on the event.
    /// Everyone: everybody else the sheet knows, A to Z, those on the event
    /// included (greyed). Searching a name: one list of matches, suggested
    /// first, then A to Z; searching a number or @username: none. Filtered
    /// to a past event: just its people, A to Z, and no Suggested (nobody
    /// at all when its guest list is hidden).
    var order: (suggested: [Person.ID], everyone: [Person.ID]) {
        if from?.isHidden == true { return ([], []) }
        let known = from.map { from in people.keys.filter(from.ids.contains) } ?? Array(people.keys)
        let suggested = from != nil ? [] : Array(suggestedIds.filter { people[$0] != nil && isPickable($0) }.prefix(Self.suggestedShown))
        let typed = query.trimmingCharacters(in: .whitespaces)
        guard !typed.isEmpty else {
            return (suggested, known.filter { !suggested.contains($0) }.sorted(by: byName))
        }
        guard LookupKind(typed) == nil else { return ([], []) }
        let needle = Self.fold(typed)
        let hits = known.filter { Self.fold(people[$0]?.person.fullName ?? "").contains(needle) }
        let top = suggested.filter(hits.contains)
        return ([], top + hits.filter { !top.contains($0) }.sorted(by: byName))
    }

    /// Letters without their accents, in lower case: "Inés" is found by "ines".
    static func fold(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US"))
    }

    private func byName(_ a: Person.ID, _ b: Person.ID) -> Bool {
        let order = (people[a]?.person.fullName ?? "").compare(
            people[b]?.person.fullName ?? "", options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US"))
        return order == .orderedSame ? a < b : order == .orderedAscending
    }
}
