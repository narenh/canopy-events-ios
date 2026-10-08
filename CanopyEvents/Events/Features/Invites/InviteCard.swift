import SwiftUI

/// One invitation: the event (tap for details) and answer buttons right
/// on the card. Also used for declined events, to change your mind.
struct InviteCard: View {
    let event: Event
    let onAnswer: (RSVPStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            NavigationLink(value: Route.event(event.id)) {
                EventCard(event: event)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if let host = event.hosts.first {
                Text("Invited by \(host.person.shortName)")
                    .font(.caption)
                    .foregroundStyle(Palette.muted)
            }

            AnswerButtons(current: event.myStatus, onAnswer: onAnswer)
        }
        .glassCard()
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            InviteCard(event: PreviewData.event(MockEvents.hikeId)) { _ in }
                .padding()
        }
        .canopyScreen()
    }
    .preferredColorScheme(.dark)
}
