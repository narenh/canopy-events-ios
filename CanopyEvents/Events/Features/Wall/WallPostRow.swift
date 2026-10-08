import SwiftUI

/// One wall entry. People's posts show who wrote them; automatic entries
/// ("Ana L is going", "Time changed") are quieter, with an icon.
struct WallPostRow: View {
    let post: WallPost

    var body: some View {
        if post.kind == .post, let author = post.author {
            HStack(alignment: .top, spacing: Spacing.medium) {
                Avatar(person: author, size: 32)
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    HStack {
                        Text(author.shortName).font(.subheadline.weight(.semibold))
                        Text(RelativeTime.string(for: post.createdAt))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(post.body)
                }
            }
        } else {
            Label {
                Text("\(post.body) · \(RelativeTime.string(for: post.createdAt))")
            } icon: {
                Image(systemName: post.kind == .rsvp ? "checkmark.circle" : "pencil.circle")
            }
            .font(.subheadline)
            .foregroundStyle(Palette.muted)
        }
    }
}

#Preview {
    List(PreviewData.posts()) { WallPostRow(post: $0) }
        .canopyScreen()
        .preferredColorScheme(.dark)
}
