import SwiftUI

/// An event's whole activity wall, newest first, with a composer at the
/// bottom. Swipe to delete what you're allowed to (your own posts, or
/// anything if you host).
struct WallView: View {
    @Environment(\.eventsRepository) private var repository
    @State private var model: WallModel

    init(eventId: Event.ID) {
        _model = State(initialValue: WallModel(eventId: eventId))
    }

    var body: some View {
        List(model.posts) { post in
            WallPostRow(post: post)
                .swipeActions {
                    if post.canDelete {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            Task { await model.delete(post, using: repository) }
                        }
                    }
                }
        }
        .overlay {
            if !model.hasLoaded {
                ProgressView()
            } else if model.posts.isEmpty {
                ContentUnavailableView("No posts yet", systemImage: "text.bubble",
                                       description: Text("Be the first to say something."))
            }
        }
        .safeAreaInset(edge: .bottom) {
            WallComposer(text: $model.draft, canPost: model.canPost) {
                Task { await model.post(using: repository) }
            }
        }
        .navigationTitle("Wall")
        .task { await model.load(from: repository) }
        .refreshable { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }
}

#Preview {
    NavigationStack { WallView(eventId: MockEvents.rooftopId) }
        .mockEnvironment()
}

#Preview("Empty") {
    NavigationStack { WallView(eventId: MockEvents.hikeId) }
        .mockEnvironment()
}
