import SwiftUI

/// The signed-in app. Everyone gets Events, Invites and Profile. Once
/// you've hosted (`session.isHost`), a Hosting tab and a "New event"
/// button in the tab bar appear, for good. Quick accounts see the
/// verify-your-email banner at the top of every screen (each tab's root
/// here, and every pushed screen in `RouteView`).
struct MainTabView: View {
    @Environment(AppSession.self) private var session
    @State private var selection = LaunchOptions.startTab ?? .events
    @State private var eventsPath: [Route] = LaunchOptions.startPath
    @State private var invitesPath: [Route] = []
    @State private var hostingPath: [Route] = []
    @State private var isCreatingEvent = LaunchOptions.opensNewEvent
    @State private var showsVerifyFirst = false

    var body: some View {
        TabView(selection: tabSelection) {
            Tab("Events", systemImage: "calendar", value: AppTab.events) {
                NavigationStack(path: $eventsPath) {
                    EventsView(onNewEvent: newEventAction)
                        .verifyEmailBanner()
                        .navigationDestination(for: Route.self) { RouteView(route: $0) }
                }
            }
            Tab("Invites", systemImage: "envelope", value: AppTab.invites) {
                NavigationStack(path: $invitesPath) {
                    InvitesView()
                        .verifyEmailBanner()
                        .navigationDestination(for: Route.self) { RouteView(route: $0) }
                }
            }
            if session.isHost {
                Tab("Hosting", systemImage: "star", value: AppTab.hosting) {
                    NavigationStack(path: $hostingPath) {
                        HostingView()
                            .verifyEmailBanner()
                            .navigationDestination(for: Route.self) { RouteView(route: $0) }
                    }
                }
            }
            Tab("Profile", systemImage: "person.crop.circle", value: AppTab.profile) {
                NavigationStack {
                    ProfileView()
                        .verifyEmailBanner()
                }
            }
            if session.isHost {
                // Never shown as a screen: `tabSelection` turns selecting it
                // into opening the editor. (On iOS 27, `role: .prominent`
                // sets it apart in the tab bar; see ARCHITECTURE.md.)
                Tab("New event", systemImage: "plus.circle.fill", value: AppTab.newEvent) {
                    Color.clear
                }
            }
        }
        .animation(.default, value: session.isHost)
        .sheet(isPresented: $isCreatingEvent) {
            EventEditorView(event: nil) { created in
                Task { await didCreate(created) }
            }
        }
        .alert("Verify your email to host", isPresented: $showsVerifyFirst) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Quick accounts can RSVP and post, but only verified accounts can create events. Use the banner above to verify.")
        }
    }

    /// The tab selection, except that choosing "New event" opens the
    /// editor and leaves you on the tab you were on.
    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selection },
            set: { newValue in
                if newValue == .newEvent {
                    startNewEvent()
                } else {
                    selection = newValue
                }
            }
        )
    }

    /// The Events tab's "+": only for people who've never hosted, since
    /// hosts get the New event button in the tab bar instead.
    private var newEventAction: (() -> Void)? {
        session.isHost ? nil : { startNewEvent() }
    }

    private func startNewEvent() {
        if session.needsVerification {
            showsVerifyFirst = true
        } else {
            isCreatingEvent = true
        }
    }

    /// After saving a new event: refresh (your first event makes you a
    /// host), then show it under Hosting.
    private func didCreate(_ event: Event) async {
        try? await session.refresh()
        selection = .hosting
        hostingPath = [.event(event.id)]
    }
}

#Preview("Host") {
    MainTabView()
        .mockEnvironment()
}

#Preview("Never hosted, unverified") {
    MainTabView()
        .mockEnvironment(signedInAs: MockPeople.sam)
}
