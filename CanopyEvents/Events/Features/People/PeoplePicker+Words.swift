import Foundation

/// The words that differ between inviting and adding to a list, and what
/// the sheets say afterwards (public/copy.js, `invite` and `lists`).
nonisolated extension PeoplePicker.Kind {
    /// The tray's button: "Invite 7" / "Add 7" ("Invite" / "Add" at 0).
    func send(_ n: Int) -> String {
        let verb = self == .invite ? "Invite" : "Add"
        return n == 0 ? verb : "\(verb) \(n)"
    }

    /// A list's button: "Invite all 3" / "Add all 3".
    func all(_ n: Int) -> String {
        self == .invite ? "Invite all \(n)" : "Add all \(n)"
    }

    /// A list with nobody left to pick: "All invited" / "All on it".
    var allDone: String {
        self == .invite ? "All invited" : "All on it"
    }
}

nonisolated extension PeoplePicker {
    /// After sending: "Invited 7 people." or "Invited 1 person."
    static func invitedNotice(_ n: Int) -> String {
        n == 1 ? "Invited 1 person." : "Invited \(n) people."
    }

    /// After adding to a list: "Added 5 people. Invited them to 1 event.",
    /// "Added 1 person.", or "Everyone you picked is on it already."
    static func addedNotice(added: Int, invitedTo: Int) -> String {
        let said = switch added {
        case 0: "Everyone you picked is on it already."
        case 1: "Added 1 person."
        default: "Added \(added) people."
        }
        return said + invitedThem(invitedTo)
    }

    /// After "Save as list": "Saved 5 people to Regulars.", then the
    /// events it invited them to, if any.
    static func savedNotice(_ n: Int, to list: String, invitedTo: Int) -> String {
        (n == 1 ? "Saved 1 person to \(list)." : "Saved \(n) people to \(list).") + invitedThem(invitedTo)
    }

    /// " Invited them to 1 event." (with its space), or nothing.
    private static func invitedThem(_ events: Int) -> String {
        switch events {
        case 0: ""
        case 1: " Invited them to 1 event."
        default: " Invited them to \(events) events."
        }
    }
}
