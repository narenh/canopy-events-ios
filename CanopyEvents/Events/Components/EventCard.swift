import SwiftUI

/// One event in a list, after the web's: the cover (or its generated
/// art) as a 3:2 thumbnail, then a bold accent line saying when ("SAT,
/// OCT 10 · 7:30 PM"), the title, where, and a tag for your part in it.
struct EventCard: View {
    let event: Event

    @Environment(\.horizontalSizeClass) private var sizeClass

    /// 116 pt on a phone, 168 pt wider, as the web's.
    private var thumbnailWidth: CGFloat { sizeClass == .regular ? 168 : 116 }

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // At accessibility sizes the words get the whole width, under the picture.
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.medium))
            : AnyLayout(HStackLayout(spacing: Spacing.medium))
        layout {
            CoverPicture(event: event)
                .frame(width: thumbnailWidth, height: thumbnailWidth * 2 / 3)
                .clipShape(.rect(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.22), lineWidth: 1) }

            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(Self.unbroken(EventDateFormatter.rowLine(for: event).uppercased()))
                    .font(Typography.listWhen)
                    .tracking(0.4)
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

    /// The line breaks only between its pieces ("SAT, OCT 10 · 7:30 PM"
    /// never splits "7:30 PM"), as the web's `unbroken` does.
    static func unbroken(_ line: String) -> String {
        line.components(separatedBy: " · ")
            .map { $0.components(separatedBy: " – ").map { $0.replacingOccurrences(of: " ", with: "\u{00A0}") }
                .joined(separator: " – ") }
            .joined(separator: " · ")
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
    ScrollView {
        VStack {
            ForEach([MockEvents.rooftopId, MockEvents.birthdayId, MockEvents.supperClubId, MockEvents.karaokeId,
                     MockEvents.galleryId], id: \.self) { EventCard(event: PreviewData.event($0)).glassCard() }
        }
        .padding()
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
