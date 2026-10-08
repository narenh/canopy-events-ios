import SwiftUI

/// The Hosting tab (hosts only): events you host or co-host that aren't
/// over, cancelled ones included, soonest first. "Past" is a pushed list.
struct HostingView: View {
    @Environment(\.eventsRepository) private var repository
    @State private var model = EventListModel(.hosting)

    var body: some View {
        List {
            Section {
                NavigationLink(value: Route.pastHostedEvents) {
                    Label("Past", systemImage: "clock.arrow.circlepath")
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
        .overlay {
            if !model.hasLoaded {
                ProgressView()
            } else if model.events.isEmpty {
                ContentUnavailableView("Nothing planned", systemImage: "star",
                                       description: Text("Use New event in the tab bar to host something."))
            }
        }
        .navigationTitle("Hosting")
        .task { await model.load(from: repository) }
        .refreshable { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }
}

#Preview {
    NavigationStack {
        HostingView()
    }
    .mockEnvironment()
}
