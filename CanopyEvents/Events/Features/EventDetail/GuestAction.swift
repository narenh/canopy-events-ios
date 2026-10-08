/// The guest menu's actions that need a yes first.
enum GuestAction: Hashable, Identifiable {
    case leave

    var id: Self { self }

    var title: String { "Remove yourself from this event?" }
    var confirmLabel: String { "Remove me" }
    var message: String {
        "You'll be off the guest list and your lists, and it can't be undone. The link still works, so you can answer again later."
    }
}
