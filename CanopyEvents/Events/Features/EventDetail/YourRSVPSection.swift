import SwiftUI

/// Your answer to the event, for guests: answer buttons, plus-ones, and
/// the waitlist. Says why when you can't answer (cancelled, over).
struct YourRSVPSection: View {
    let event: Event
    var isSaving = false
    /// Answer right away (no plus-ones to ask about).
    let onAnswer: (RSVPStatus) -> Void
    /// Open the RSVP sheet, preset to this answer, to choose plus-ones.
    let onAnswerWithGuests: (RSVPStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            SectionHeader(title: "Your RSVP")
            if event.isCancelled {
                Text("This event was cancelled.")
                    .foregroundStyle(Palette.danger)
            } else if event.isOver {
                Text(event.myStatus.map { "You said \($0.title.lowercased())." } ?? "This event is over.")
                    .foregroundStyle(Palette.muted)
            } else {
                AnswerButtons(current: event.myStatus, isDisabled: isSaving, onAnswer: answer)
                if let guests = event.viewer?.rsvp?.guests, guests > 0 {
                    Text("Bringing \(guests) \(guests == 1 ? "guest" : "guests")")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                }
                if event.myStatus == .waitlisted {
                    WaitlistNotice(isOnWaitlist: true)
                } else if event.isFull && event.myStatus != .going {
                    WaitlistNotice(isOnWaitlist: false)
                }
            }
        }
        .glassCard()
    }

    /// Going or maybe to an event that allows plus-ones asks how many.
    private func answer(_ status: RSVPStatus) {
        if status != .notGoing && event.plusOnesAllowed > 0 {
            onAnswerWithGuests(status)
        } else {
            onAnswer(status)
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            YourRSVPSection(event: PreviewData.event(MockEvents.rooftopId), onAnswer: { _ in }, onAnswerWithGuests: { _ in })
            YourRSVPSection(event: PreviewData.event(MockEvents.supperClubId), onAnswer: { _ in }, onAnswerWithGuests: { _ in })
            YourRSVPSection(event: PreviewData.event(MockEvents.karaokeId), onAnswer: { _ in }, onAnswerWithGuests: { _ in })
            YourRSVPSection(event: PreviewData.event(MockEvents.hikeId), onAnswer: { _ in }, onAnswerWithGuests: { _ in })
        }
        .padding()
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
