import SwiftUI

/// One event in a list: cover thumbnail, title, when and where, and a tag
/// for your part in it (hosting, your RSVP, or cancelled).
struct EventCard: View {
    let event: Event

    var body: some View {
        HStack(spacing: Spacing.medium) {
            CoverImage(url: event.coverImageUrl)
                .frame(width: 64, height: 64)
                .clipShape(.rect(cornerRadius: Radius.small))

            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(event.title)
                    .font(Typography.cardTitle)
                    .strikethrough(event.isCancelled)
                    .lineLimit(2)
                Text("\(EventDateFormatter.day(for: event)) · \(EventDateFormatter.startTime(for: event))")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                if let place = event.locationName {
                    Text(place)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
            TagLabel(title: "Hosting", systemImage: "star.fill")
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
