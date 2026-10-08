import SwiftUI

/// The app's entry point. Owns the session and the notification
/// responder, which becomes the notification center's delegate here, at
/// launch, so a notification tapped to launch the app is caught.
@main
struct CanopyEventsApp: App {
    @State private var session: AppSession
    @State private var notifications: NotificationResponder

    init() {
        let session = AppSession.mock()
        let notifications = NotificationResponder(session: session)
        notifications.register()
        _session = State(initialValue: session)
        _notifications = State(initialValue: notifications)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .environment(notifications)
        }
    }
}
