import SwiftUI

/// The Events tab: everything you're going to, maybe at or waitlisted
/// for, soonest first. Hosted events live in the Hosting tab instead.
/// "Past events" is a pushed list.
struct EventsView: View {
    /// Shows a "+" in the toolbar when set. `MainTabView` passes it only to
    /// people who've never hosted; hosts use the tab bar's New event button.
    var onNewEvent: (() -> Void)?

    @Environment(\.eventsRepository) private var repository
    @State private var model = EventListModel(.upcoming)

    var body: some View {
        List {
            Section {
                NavigationLink(value: Route.pastEvents) {
                    Label("Past events", systemImage: "clock.arrow.circlepath")
                }
            }
            Section {
                ForEach(model.events) { event in
                    NavigationLink(value: Route.event(event.id)) {
                        EventCard(event: event)
                    }
                }
            }
        }
        .overlay { emptyState }
        .navigationTitle("Events")
        .toolbar {
            if let onNewEvent {
                Button("New event", systemImage: "plus", action: onNewEvent)
            }
        }
        .task { await model.load(from: repository) }
        .refreshable { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }

    @ViewBuilder private var emptyState: some View {
        if !model.hasLoaded {
            ProgressView()
        } else if model.events.isEmpty {
            ContentUnavailableView(
                "Nothing coming up",
                systemImage: "calendar",
                description: Text("Events you're going to show up here.")
            )
        }
    }
}

#Preview("Maya") {
    NavigationStack {
        EventsView()
    }
    .mockEnvironment()
}

#Preview("Empty, never hosted") {
    NavigationStack {
        EventsView(onNewEvent: {})
    }
    .mockEnvironment(signedInAs: MockPeople.ada)
}
