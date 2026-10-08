import SwiftUI

/// Internal builds only (debug and TestFlight, never the App Store; see
/// `BuildEnvironment`): send the test notification (Adam Smith inviting
/// you to Throw Eggs at Karl) 5 seconds out, so you can lock the phone and
/// see it, with Going and Can't Go, and long-press it for the card; or
/// look at that card here. Also `-mockTestNotification YES` and
/// `-mockCard YES` (debug, handled by `MainTabView`).
struct ProfileDebugSection: View {
    @Environment(\.eventsRepository) private var repository
    @State private var status: String?
    @State private var card: NotificationCard?

    var body: some View {
        Section {
            Button("Send test notification", systemImage: "bell.badge") {
                Task { await send() }
            }
            Button("Show the notification's card", systemImage: "rectangle.portrait.on.rectangle.portrait") {
                Task { card = try? await NotificationCard.load(MockEvents.eggsId, from: repository) }
            }
            if let status {
                Text(status)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
        } header: {
            Text("Debug (TestFlight only)")
        }
        .sheet(item: $card) { NotificationCardPreview(card: $0) }
    }

    private func send() async {
        guard await NotificationPermission.requestIfUndetermined() else {
            status = "Notifications are off for Events. Turn them on in Settings, then try again."
            return
        }
        do {
            try await LocalNotifications.scheduleTestInvite(using: repository, after: 5)
            status = "Coming in 5 seconds. Lock the phone to see it, and long-press it for the card."
        } catch {
            status = "Couldn't schedule it: \(error.localizedDescription)"
        }
    }
}
