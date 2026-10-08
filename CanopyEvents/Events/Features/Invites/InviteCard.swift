import SwiftUI

/// One invitation: the event (tap for details) and Going / Can't Go right
/// on the card, as the web's. A declined event's card has no buttons: its
/// answer is a small "Can't Go ▾" pill that answers again.
struct InviteCard: View {
    let event: Event
    /// A declined event's card: the answer pill, no buttons.
    var isDeclined = false
    let onAnswer: (RSVPStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            NavigationLink(value: Route.event(event.id)) {
                EventCard(event: event, onChangeAnswer: isDeclined ? onAnswer : nil)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if let host = event.hosts.first {
                Text("Invited by \(host.person.shortName)")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }

            if !isDeclined {
                AnswerButtons(current: nil, answers: [.going, .notGoing], onAnswer: onAnswer)
            }
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
