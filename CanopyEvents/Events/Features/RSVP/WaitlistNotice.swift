import SwiftUI

/// Explains the waitlist: either that you're on it, or that answering
/// "going" now will put you on it because the event is full.
struct WaitlistNotice: View {
    /// True if you're already waitlisted; false if the event is full and
    /// you're about to answer.
    let isOnWaitlist: Bool

    var body: some View {
        Label {
            Text(isOnWaitlist
                 ? "You're on the waitlist. If a spot opens up, you'll move to going automatically and get a notification."
                 : "This event is full. Saying going puts you on the waitlist, and you'll move up automatically if a spot opens.")
        } icon: {
            Image(systemName: "hourglass")
        }
        .font(.subheadline)
        .foregroundStyle(.orange)
    }
}

#Preview {
    VStack(spacing: Spacing.large) {
        WaitlistNotice(isOnWaitlist: true)
        WaitlistNotice(isOnWaitlist: false)
    }
    .padding()
    .preferredColorScheme(.dark)
}
