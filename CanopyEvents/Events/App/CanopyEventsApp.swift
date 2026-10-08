import SwiftUI

/// The app's entry point. Owns the session and hands it to `RootView`.
@main
struct CanopyEventsApp: App {
    @State private var session = AppSession.mock()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
    }
}
