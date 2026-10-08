import SwiftUI

/// One invitation: the event (tap for details) and Going / Can't Go right
/// on the card, as the web's. A declined event's card offers just Going,
/// to change your mind.
struct InviteCard: View {
    let event: Event
    var answers: [RSVPStatus] = [.going, .notGoing]
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
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }

            AnswerButtons(current: event.myStatus == .notGoing ? nil : event.myStatus, answers: answers, onAnswer: onAnswer)
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
