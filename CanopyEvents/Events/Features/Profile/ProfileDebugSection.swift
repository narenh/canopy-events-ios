#if DEBUG
import SwiftUI

/// Debug builds only: send the test notification (Karl Marx inviting you
/// to Marxism 101) 5 seconds out, so you can lock the phone and see it,
/// with Going and Can't Go. Also `-mockTestNotification YES`.
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
            try await LocalNotifications.schedule(MockNotifications.karlInvite, after: 5)
            status = "Coming in 5 seconds. Lock the phone to see it on the Lock Screen."
        } catch {
            status = "Couldn't schedule it: \(error.localizedDescription)"
        }
    }
}
#endif
