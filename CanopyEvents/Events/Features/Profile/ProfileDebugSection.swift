import SwiftUI

/// Developer tools, shown in every build while the app is in development:
/// send the test notification (Adam Smith inviting
/// you to Throw Eggs at Karl) 5 seconds out, so you can lock the phone and see
/// it, with Going and Can't Go. Also `-mockTestNotification YES` (debug).
struct ProfileDebugSection: View {
    @State private var status: String?

    var body: some View {
        Section {
            Button("Send test notification", systemImage: "bell.badge") {
                Task { await send() }
            }
            if let status {
                Text(status)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
        } header: {
            Text("Debug")
        }
    }

    private func send() async {
        guard await NotificationPermission.requestIfUndetermined() else {
            status = "Notifications are off for Events. Turn them on in Settings, then try again."
            return
        }
        do {
            try await LocalNotifications.schedule(MockNotifications.adamInvite, after: 5)
            status = "Coming in 5 seconds. Lock the phone to see it on the Lock Screen."
        } catch {
            status = "Couldn't schedule it: \(error.localizedDescription)"
        }
    }
}
