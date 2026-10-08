import SwiftUI

/// The signed-in app. Everyone gets Events, Invites and Profile. Once
/// you've hosted (`session.isHost`), a Hosting tab and a "New event"
/// button in the tab bar appear, for good. Quick accounts see the
/// verify-your-email banner at the top of every screen (each tab's root
/// here, and every pushed screen in `RouteView`).
struct MainTabView: View {
    @Environment(AppSession.self) private var session
    @Environment(NotificationResponder.self) private var notifications
    @State private var selection = LaunchOptions.startTab ?? .events
    @State private var eventsPath: [Route] = LaunchOptions.startPath
    @State private var invitesPath: [Route] = []
    @State private var hostingPath: [Route] = []
    @State private var isCreatingEvent = LaunchOptions.opensNewEvent
    @State private var showsVerifyFirst = false
    /// `-mockCard YES`: the expanded notification's card, to look at.
    @State private var launchCard: NotificationCard?

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
        // Signed in: now's the moment to ask about notifications.
        .task {
            guard !LaunchOptions.showsNotificationCard else { return }  // a screenshot of the card, unobstructed
            if await NotificationPermission.requestIfUndetermined(), LaunchOptions.sendsTestNotification {
                try? await LocalNotifications.scheduleTestInvite(using: session.repository)
            }
        }
        .task {
            if LaunchOptions.showsNotificationCard {
                launchCard = try? await NotificationCard.load(MockEvents.eggsId, from: session.repository)
            }
        }
        .sheet(item: $launchCard) { NotificationCardPreview(card: $0) }
        .onChange(of: notifications.opening) { _, opening in
            guard let opening else { return }
            show(opening)
            notifications.opening = nil
        }
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

    /// A tapped notification's event, on its tab.
    private func show(_ opening: OpenedEvent) {
        selection = opening.tab
        switch opening.tab {
        case .invites: invitesPath = [.event(opening.eventId)]
        default: eventsPath = [.event(opening.eventId)]
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
