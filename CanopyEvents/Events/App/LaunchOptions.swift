import Foundation

/// Launch arguments that jump straight to a screen, for quick checks and
/// simulator screenshots. Set them in the scheme's "Arguments Passed On
/// Launch" or with `xcrun simctl launch booted com.canopysf.CanopyEvents
/// -mockAccount maya -mockTab invites`. Ignored in release builds.
enum LaunchOptions {
    /// `maya` (verified host), `quick` (Sam, unverified, one invite) or
    /// `new` (a brand-new quick sign-up with no history).
    static var mockAccount: String? { value(for: "mockAccount") }
    /// `events`, `invites`, `hosting` or `profile`.
    static var startTab: AppTab? { value(for: "mockTab").flatMap(AppTab.init(rawValue:)) }
    /// An event id to open on the Events tab, e.g. `4fQ9xKpL2mZa`.
    static var openEventId: String? { value(for: "mockEvent") }
    /// What the Events tab opens with: `-mockEvent <id>`, then `-mockPush
    /// wall` for that event's updates, or `-mockPush past|listLink` alone
    /// (Ana's Dumpling crew's join screen).
    static var startPath: [Route] {
        let event = openEventId
        switch value(for: "mockPush") {
        case "past": return [.pastEvents]
        case "listLink": return [.listLink(MockLists.dumplingCrewCode)]
        case "wall": return event.map { [.event($0), .wall($0)] } ?? []
        default: return event.map { [.event($0)] } ?? []
        }
    }
    /// `YES`, with `-mockEvent`, opens that event's guests sheet.
    static var showsGuests: Bool { value(for: "mockGuests") == "YES" }
    /// `YES` opens Maya's Drag Race's sheet on Profile (with `-mockTab
    /// profile`); `add` opens it on its "Add people" step.
    static var opensList: Bool { ["YES", "add"].contains(value(for: "mockList")) }
    /// `-mockList add`, until the sheet has opened that step once.
    static var addsToOpenList = value(for: "mockList") == "add"
    /// `YES`, with `-mockEvent`, opens that event's editor too.
    static var editsOpenEvent: Bool { value(for: "mockEdit") == "YES" }
    /// `YES`, with `-mockEvent`, opens "Duplicate" on that event (one you host).
    static var duplicatesOpenEvent: Bool { value(for: "mockDuplicate") == "YES" }
    /// `YES`, with `-mockEvent`, opens that event's invite sheet too.
    static var invitesOpenEvent: Bool { value(for: "mockInvite") == "YES" }
    /// `YES` sends the test notification (Adam Smith's invite) 5 seconds
    /// after signing in, once notifications are allowed.
    static var sendsTestNotification: Bool { value(for: "mockTestNotification") == "YES" }
    /// `YES` shows the expanded notification's card (Profile's Debug
    /// section has it too).
    static var showsNotificationCard: Bool { value(for: "mockCard") == "YES" }
    /// `YES` doesn't ask for notification permission (for screenshots).
    static var skipsPermission: Bool { value(for: "mockNoPermission") == "YES" }
    /// `YES` opens the new-event editor on launch.
    static var opensNewEvent: Bool { value(for: "mockNewEvent") == "YES" }

    private static func value(for key: String) -> String? {
        #if DEBUG
        UserDefaults.standard.string(forKey: key)
        #else
        nil
        #endif
    }
}
