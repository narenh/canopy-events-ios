/// The main tabs, in order. Raw values are for `-mockTab` (LaunchOptions). `hosting` and `newEvent` only appear once
/// you've hosted something (`AppSession.isHost`).
enum AppTab: String, Hashable, CaseIterable {
    /// What you're going to, maybe at, or waitlisted for.
    case events
    /// Invitations you haven't answered.
    case invites
    /// Events you host or co-host. Hosts only.
    case hosting
    /// You, your contact details, and sign out.
    case profile
    /// Not a real screen: selecting it opens the new-event editor. Hosts only.
    case newEvent
}
