import SwiftUI

/// Counts and a few faces from the guest list, linking to the full list.
/// When the names are hidden, only the counts show.
struct GuestListPreviewSection: View {
    let event: Event
    let guestList: GuestList?

    private var going: [Person] {
        guestList?.guests(with: .going).map(\.person) ?? []
    }

    var body: some View {
        NavigationLink(value: Route.guestList(event.id)) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    SectionHeader(title: "Guest list")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Palette.muted)
                }
                RSVPCountsView(counts: event.counts)
                if guestList?.guestsVisible == true {
                    if !going.isEmpty { AvatarStack(people: going) }
                } else {
                    Label("Names show once you've RSVP'd.", systemImage: "eye.slash")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                }
            }
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        VStack {
            GuestListPreviewSection(event: PreviewData.event(MockEvents.rooftopId),
                                    guestList: PreviewData.guestList(MockEvents.rooftopId))
            GuestListPreviewSection(event: PreviewData.event(MockEvents.hikeId),
                                    guestList: PreviewData.guestList(MockEvents.hikeId))
        }
        .padding()
        .canopyScreen()
    }
    .preferredColorScheme(.dark)
}
