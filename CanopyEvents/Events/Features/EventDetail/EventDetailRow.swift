import SwiftUI

/// One of the host's extra fields on the event page, as the web draws it
/// (docs/api.md, "Event details"): its icon in the accent, then a link or
/// a phone on one line (the link's label or its shortened address; a
/// phone as "label · number", the number the link), or a heading over
/// plain text with its line breaks kept. Only http(s) and tel: links open.
struct EventDetailRow: View {
    let detail: EventDetail

    @Environment(\.eventAccent) private var accent

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.medium) {
            Image(systemName: detail.type.systemImage)
                .foregroundStyle(accent.accent)
                .frame(width: 22)
            content
        }
    }

    @ViewBuilder private var content: some View {
        switch detail.type {
        case .link:
            link(detail.linkText)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(detail.value)
        case .phone:
            HStack(spacing: Spacing.xSmall) {
                if let label = detail.label {
                    Text(label).fontWeight(.semibold)
                    Text("·").foregroundStyle(Palette.muted)
                }
                link(detail.value)
            }
            .lineLimit(1)
        default:
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                if let heading = detail.heading {
                    Text(heading).fontWeight(.semibold)
                }
                Text(verbatim: detail.value)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder private func link(_ words: String) -> some View {
        if let url = detail.url {
            Link(destination: url) { Text(verbatim: words) }
                .fontWeight(.semibold)
                .accentLink(accent)
        } else {
            Text(verbatim: words).fontWeight(.semibold)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.large) {
        ForEach(PreviewData.event(MockEvents.rooftopId).details, id: \.self) { EventDetailRow(detail: $0) }
        ForEach(PreviewData.event(MockEvents.supperClubId).details, id: \.self) { EventDetailRow(detail: $0) }
    }
    .padding()
    .canopyScreen(theme: .hue(225))
}
