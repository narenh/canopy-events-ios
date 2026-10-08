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
    /// The ⋯ beside the heading, for a guest on the event; nil for none.
    var menu: GuestMenu?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                Text(heading)
                    .font(Typography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)
                if event.viewer?.muted == true {
                    Image(systemName: "bell.slash")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                        .accessibilityLabel("Muted")
                }
                Spacer()
                if let menu { menu }
            }
            if event.isCancelled {
                Text("This event was cancelled.")
                    .foregroundStyle(Palette.danger)
            } else if event.myStatus == .removed {
                Text("A host took you off this event.")
                    .foregroundStyle(Palette.muted)
            } else if event.isOver {
                Text(event.myStatus.map { "You said \($0.title.lowercased())." } ?? "This event is over.")
                    .foregroundStyle(Palette.muted)
            } else {
                AnswerButtons(current: event.myStatus, isDisabled: isSaving, onAnswer: answer)
                if let rsvp = event.viewer?.rsvp, rsvp.guests > 0 {
                    Text("Bringing \(rsvp.guests) \(rsvp.guests == 1 ? "guest" : "guests")")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                    if rsvp.guestsOverLimit {
                        Text("The host now allows \(event.guestsAllowed) per RSVP. Your answer stands; a change has to fit.")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                }
                if event.myStatus == .waitlisted {
                    WaitlistNotice(isOnWaitlist: true)
                } else if event.isFull && event.myStatus != .going {
                    WaitlistNotice(isOnWaitlist: false)
                }
            }
        }
        .controlSize(.large)
        .glassCard()
    }

    private var heading: String {
        if event.isCancelled || event.isOver || event.myStatus == .removed { return "Your RSVP" }
        return "RSVP"
    }

    /// Going or maybe to an event that allows plus-ones asks how many.
    private func answer(_ status: RSVPStatus) {
        if status != .notGoing && event.guestsAllowed > 0 {
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
