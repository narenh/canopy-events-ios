import SwiftUI

/// An event's activity wall, newest first, with a composer at the bottom
/// for those who may post. Swipe to delete what you're allowed to (your
/// own posts, or anything if you host). Hidden, like the guest list's
/// names, until you may see them.
struct WallView: View {
    @Environment(\.eventsRepository) private var repository
    @State private var model: WallModel

    init(eventId: Event.ID) {
        _model = State(initialValue: WallModel(eventId: eventId))
    }

    var body: some View {
        List(model.entries) { entry in
            WallEntryRow(entry: entry)
                .glassRowBackground()
                .swipeActions {
                    if entry.canDelete {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            Task { await model.delete(entry, using: repository) }
                        }
                    }
                }
        }
        .overlay {
            if let wall = model.wall {
                if !wall.wallVisible {
                    ContentUnavailableView("Wall hidden", systemImage: "eye.slash",
                                           description: Text("The wall shows once you've RSVP'd."))
                } else if model.entries.isEmpty {
                    ContentUnavailableView("No posts yet", systemImage: "text.bubble",
                                           description: Text("Be the first to say something."))
                }
            } else {
                ProgressView()
            }
        }
        .safeAreaInset(edge: .bottom) {
            if model.wall?.canPost == true {
                WallComposer(text: $model.draft, canPost: model.canSend) {
                    Task { await model.post(using: repository) }
                }
            }
        }
        .navigationTitle("Wall")
        .inlineNavigationTitle()
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
    NavigationStack { WallView(eventId: MockEvents.potteryId) }
        .mockEnvironment(signedInAs: MockPeople.sam)
}

#Preview("Hidden until you RSVP") {
    NavigationStack { WallView(eventId: MockEvents.hikeId) }
        .mockEnvironment()
}
