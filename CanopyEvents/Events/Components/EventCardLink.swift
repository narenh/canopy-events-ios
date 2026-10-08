import SwiftUI

/// An event in a list as its own glass card, opening the event: the
/// lists' building block, like the web's home rows.
struct EventCardLink: View {
    let event: Event

    var body: some View {
        NavigationLink(value: Route.event(event.id)) {
            EventCard(event: event)
                .contentShape(.rect)
                .padding(-Spacing.xSmall)
                .glassCard()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack {
                EventCardLink(event: PreviewData.event(MockEvents.rooftopId))
                EventCardLink(event: PreviewData.event(MockEvents.gameNightId))
            }
            .padding()
        }
        .canopyScreen()
    }
}
