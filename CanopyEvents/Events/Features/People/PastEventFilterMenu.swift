import SwiftUI

/// "Filter by past event": a menu of your past events, each by title and
/// date, most recent first, after "Everyone" (no filter). Picking one
/// narrows a picker to its people; it ticks nobody.
struct PastEventFilterMenu: View {
    let events: [Event]
    /// The event filtered to; nil for everyone.
    @Binding var selection: Event.ID?

    var body: some View {
        Picker("Filter by past event", systemImage: "clock.arrow.circlepath", selection: $selection) {
            Text("Everyone").tag(Event.ID?.none)
            ForEach(events) { event in
                Text("\(event.title), \(day(event))").tag(Event.ID?.some(event.id))
            }
        }
        .pickerStyle(.menu)
    }

    private func day(_ event: Event) -> String {
        var style = Date.FormatStyle.dateTime.month(.abbreviated).day()
        style.timeZone = event.eventTimeZone
        return event.startsAt.formatted(style)
    }
}

#Preview {
    @Previewable @State var selection: Event.ID?
    List {
        PastEventFilterMenu(events: [PreviewData.event(MockEvents.bonfireId), PreviewData.event(MockEvents.snatchGameId)],
                            selection: $selection)
    }
    .canopyScreen()
}
