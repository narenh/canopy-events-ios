/// The host's ⋯ menu actions that need a yes first, with what the
/// confirmation says. (Co-hosts… opens a sheet instead.)
enum HostAction: Hashable, Identifiable {
    case newLink
    case cancel
    case bringBack
    case delete
    case stepDown

    var id: Self { self }

    var title: String {
        switch self {
        case .newLink: "Make a new link?"
        case .cancel: "Cancel this event?"
        case .bringBack: "Bring this event back?"
        case .delete: "Delete this event?"
        case .stepDown: "Step down as co-host?"
        }
    }

    var confirmLabel: String {
        switch self {
        case .newLink: "Make a new link"
        case .cancel: "Cancel event"
        case .bringBack: "Bring back event"
        case .delete: "Delete event"
        case .stepDown: "Step down"
        }
    }

    var isDestructive: Bool { self == .cancel || self == .delete || self == .stepDown }

    /// What happens, in a sentence or two. Deleting warns when people have
    /// said going or maybe: nobody is told, and cancelling would tell them.
    func message(for event: Event) -> String {
        switch self {
        case .newLink:
            return "The old link stops working at once. Everything else stays. Nobody is told, so share the new link with whoever should have it."
        case .cancel:
            return "Everyone going, maybe or on the waitlist is told. The link keeps working and shows it's cancelled."
        case .bringBack:
            return "It's back on for everyone who answered, and the waitlist fills any open spots."
        case .delete:
            let answered = event.counts.going + event.counts.maybe
            guard answered > 0, !event.isOver else { return "\(event.title) and its guest list and updates go for good." }
            return "\(answered) \(answered == 1 ? "person has" : "people have") said going or maybe. Deleting doesn't tell them; cancelling does, and keeps the event to open."
        case .stepDown:
            return "You'll be invited like any guest, and can answer."
        }
    }
}
