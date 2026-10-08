import SwiftUI

/// Events that are over, most recent first. Pushed from Events (the ones
/// you went to) or from Hosting (the ones you hosted).
struct PastEventsView: View {
    /// True for the Hosting tab's list, false for the Events tab's.
    let showsHosted: Bool

    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @State private var model = EventListModel(.past)

    private var events: [Event] {
        model.events.filter { ($0.viewer?.isHost ?? false) == showsHosted }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.medium) {
                ForEach(events) { EventCardLink(event: $0) }
            }
            .padding(Spacing.large)
        }
        .overlay {
            if !model.hasLoaded {
                ProgressView()
            } else if events.isEmpty {
                ContentUnavailableView("No past events", systemImage: "clock",
                                       description: Text("Events that are over will show up here."))
            }
        }
        .navigationTitle(showsHosted ? "Past hosted" : "Past events")
        .task(id: session.dataVersion) { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }
}

#Preview("Went to") {
    NavigationStack {
        PastEventsView(showsHosted: false)
    }
    .mockEnvironment()
}

#Preview("Hosted") {
    NavigationStack {
        PastEventsView(showsHosted: true)
    }
    .mockEnvironment()
}

#Preview("Empty") {
    NavigationStack {
        PastEventsView(showsHosted: false)
    }
    .mockEnvironment(signedInAs: MockPeople.ada)
}
