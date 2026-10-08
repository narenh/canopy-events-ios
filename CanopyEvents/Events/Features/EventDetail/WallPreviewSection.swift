import SwiftUI

/// The latest wall entries, linking to the whole wall.
struct WallPreviewSection: View {
    let eventId: Event.ID
    let entries: [WallEntry]
    /// False while you can't see the wall (the guest list's names are hidden).
    var isVisible = true

    var body: some View {
        NavigationLink(value: Route.wall(eventId)) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    SectionHeader(title: "Wall")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Palette.muted)
                }
                if !isVisible {
                    Label("The wall shows once you've RSVP'd.", systemImage: "eye.slash")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                } else if entries.isEmpty {
                    Text("No posts yet. Say something!")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                } else {
                    ForEach(entries) { WallEntryRow(entry: $0) }
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
            WallPreviewSection(eventId: MockEvents.rooftopId, entries: Array(PreviewData.wallEntries().prefix(2)))
            WallPreviewSection(eventId: MockEvents.potteryId, entries: [])
            WallPreviewSection(eventId: MockEvents.hikeId, entries: [], isVisible: false)
        }
        .padding()
        .canopyScreen()
    }
    .preferredColorScheme(.dark)
}
