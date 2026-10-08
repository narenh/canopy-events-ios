/// An event a tapped notification asks the app to show, and the tab to
/// show it on (an invitation on Invites; anything else on Events).
struct OpenedEvent: Hashable {
    let eventId: Event.ID
    let tab: AppTab

    init(_ payload: NotificationPayload) {
        eventId = payload.eventId
        tab = payload.type == .invited ? .invites : .events
    }
}
