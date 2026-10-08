import SwiftUI

/// One wall entry. People's posts show who wrote them; the server's own
/// entries ("Ana L is going", "Time changed") are quieter, with an icon,
/// worded by `WallEntryText`. A type the app doesn't know shows nothing.
struct WallEntryRow: View {
    let entry: WallEntry

    var body: some View {
        if entry.type == .post, let author = entry.person {
            HStack(alignment: .top, spacing: Spacing.medium) {
                Avatar(person: author, size: 32)
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    HStack {
                        Text(author.shortName).font(.subheadline.weight(.semibold))
                        Text(RelativeTime.string(for: entry.createdAt))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(entry.text ?? "")
                }
            }
        } else if let sentence = WallEntryText.string(for: entry) {
            Label {
                Text("\(sentence) · \(RelativeTime.string(for: entry.createdAt))")
            } icon: {
                Image(systemName: WallEntryText.systemImage(for: entry.type))
            }
            .font(.subheadline)
            .foregroundStyle(Palette.muted)
        }
    }
}

#Preview {
    List(PreviewData.wallEntries()) { WallEntryRow(entry: $0) }
        .canopyScreen()
        .preferredColorScheme(.dark)
}

#Preview("Co-host and going") {
    List(PreviewData.wallEntries(MockEvents.birthdayId)) { WallEntryRow(entry: $0) }
        .canopyScreen()
        .preferredColorScheme(.dark)
}
