import SwiftUI

/// The latest wall posts, linking to the whole wall.
struct WallPreviewSection: View {
    let eventId: Event.ID
    let posts: [WallPost]

    var body: some View {
        NavigationLink(value: Route.wall(eventId)) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    SectionHeader(title: "Wall")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Palette.muted)
                }
                if posts.isEmpty {
                    Text("No posts yet. Say something!")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                } else {
                    ForEach(posts) { WallPostRow(post: $0) }
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
            WallPreviewSection(eventId: MockEvents.rooftopId, posts: Array(PreviewData.posts().prefix(2)))
            WallPreviewSection(eventId: MockEvents.hikeId, posts: [])
        }
        .padding()
        .canopyScreen()
    }
    .preferredColorScheme(.dark)
}
