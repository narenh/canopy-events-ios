import SwiftUI

/// The title and when, straight under the cover's band: the two things a
/// guest opening the link needs at once. The title is struck through for
/// a cancelled event; the zone is said only when it isn't your clock.
struct EventHeadView: View {
    let event: Event

    var body: some View {
        let base = ThemeColors(event.theme).base
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(event.title)
                .font(Typography.eventTitle)
                .strikethrough(event.isCancelled)
                .foregroundStyle(.white)
                .shadow(color: base.color(opacity: 0.85), radius: 7, y: 2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(EventDateFormatter.headDate(for: event))
                    .font(Typography.whenDate)
                Text(EventDateFormatter.headTime(for: event))
                    .font(Typography.whenTime)
                if let note = EventDateFormatter.zoneNote(for: event) {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                        .padding(.top, Spacing.xSmall)
                }
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.xLarge) {
        EventHeadView(event: PreviewData.event(MockEvents.rooftopId))
        EventHeadView(event: PreviewData.event(MockEvents.galleryId))
        EventHeadView(event: PreviewData.event(MockEvents.karaokeId))
    }
    .padding()
    .canopyScreen()
}
