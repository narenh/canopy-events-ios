import SwiftUI

/// One event in a list, after the web's: the cover (or its generated
/// art) as a 3:2 thumbnail, then a bold accent line saying when ("SAT,
/// OCT 10 · 7:30 PM"), the title, where, and a tag for your part in it.
struct EventCard: View {
    let event: Event

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        HStack(spacing: Spacing.medium) {
            CoverPicture(event: event)
                .frame(width: sizeClass == .regular ? 168 : 116)
                .aspectRatio(3 / 2, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.22), lineWidth: 1) }

            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(EventDateFormatter.rowLine(for: event).uppercased())
                    .font(Typography.listWhen)
                    .tracking(0.6)
                    .foregroundStyle(Palette.link)
                Text(event.title)
                    .font(Typography.listTitle)
                    .strikethrough(event.isCancelled)
                    .lineLimit(2)
                if let place = event.locationName {
                    Text(place)
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                        .lineLimit(1)
                }
                tag
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.xSmall)
    }

    @ViewBuilder private var tag: some View {
        if event.isCancelled {
            TagLabel(title: "Cancelled", systemImage: "xmark.octagon", tint: Palette.danger)
        } else if event.viewer?.isHost == true {
            TagLabel(title: event.viewer?.role == .cohost ? "Co-hosting" : "Hosting", systemImage: "star.fill")
        } else if let status = event.myStatus {
            RSVPStatusBadge(status: status)
        }
    }
}

#Preview {
    List {
        EventCard(event: PreviewData.event(MockEvents.rooftopId))
        EventCard(event: PreviewData.event(MockEvents.birthdayId))
        EventCard(event: PreviewData.event(MockEvents.supperClubId))
        EventCard(event: PreviewData.event(MockEvents.karaokeId))
        EventCard(event: PreviewData.event(MockEvents.galleryId))
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
