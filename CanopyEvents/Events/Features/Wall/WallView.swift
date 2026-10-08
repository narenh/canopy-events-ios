import SwiftUI

/// An event's activity wall, newest first, with a composer at the bottom
/// for those who may post. Swipe to delete what you're allowed to (your
/// own posts, or anything if you host). Hidden, like the guest list's
/// names, until you may see them.
struct WallView: View {
    @Environment(\.eventsRepository) private var repository
    @State private var model: WallModel
    /// The entry waiting for "Delete this post?" / "Delete this update?".
    @State private var deleting: WallEntry?

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
                            deleting = entry
                        }
                    }
                }
        }
        .overlay {
            if let wall = model.wall {
                if !wall.wallVisible {
                    ContentUnavailableView("Updates", systemImage: "eye.slash",
                                           description: Text("The host shows updates to people who've answered. Answer to see them."))
                } else if model.entries.isEmpty {
                    ContentUnavailableView(wall.canPost ? "Nothing here yet. Say hello to everyone coming." : "Nothing here yet.",
                                           systemImage: "text.bubble")
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
        .navigationTitle("Updates")
        .confirmationDialog(deleting?.type == .post ? "Delete this post?" : "Delete this update?",
                            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
                            titleVisibility: .visible, presenting: deleting) { entry in
            Button("Delete", role: .destructive) { Task { await model.delete(entry, using: repository) } }
        }
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
