import SwiftUI

/// "Invite everyone from…" one of your past events: each by title and
/// date, most recent first.
struct InviteFromPastMenu: View {
    let events: [Event]
    let onPick: (Event) -> Void

    var body: some View {
        Menu {
            ForEach(events) { event in
                Button("\(event.title) · \(day(event))") { onPick(event) }
            }
        } label: {
            HStack {
                Label("Invite everyone from…", systemImage: "clock.arrow.circlepath")
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
        }
    }

    private func day(_ event: Event) -> String {
        var style = Date.FormatStyle.dateTime.month(.abbreviated).day()
        style.timeZone = event.eventTimeZone
        return event.startsAt.formatted(style)
    }
}

#Preview {
    List {
        InviteFromPastMenu(events: [PreviewData.event(MockEvents.bonfireId), PreviewData.event(MockEvents.snatchGameId)]) { _ in }
    }
    .canopyScreen()
}
