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
    /// What the Events tab opens with: `-mockEvent <id>`, then
    /// `-mockPush guests|wall` for that event's screen, or `-mockPush
    /// past|declined` alone.
    static var startPath: [Route] {
        let event = openEventId
        switch value(for: "mockPush") {
        case "past": return [.pastEvents]
        case "declined": return [.declinedEvents]
        case "guests": return event.map { [.event($0), .guestList($0)] } ?? []
        case "wall": return event.map { [.event($0), .wall($0)] } ?? []
        default: return event.map { [.event($0)] } ?? []
        }
    }
    /// `YES`, with `-mockEvent`, opens that event's editor too.
    static var editsOpenEvent: Bool { value(for: "mockEdit") == "YES" }
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
