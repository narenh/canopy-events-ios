import SwiftUI

/// Events you said you can't go to that haven't happened yet, so you can
/// change your answer. Pushed from the Invites tab.
struct DeclinedEventsView: View {
    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @State private var model = EventListModel(.declined)

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.large) {
                ForEach(model.events) { event in
                    InviteCard(event: event) { status in
                        Task { await model.answer(event, with: status, using: repository) }
                    }
                }
            }
            .padding(Spacing.large)
            .animation(.default, value: model.events)
        }
        .overlay {
            if !model.hasLoaded {
                ProgressView()
            } else if model.events.isEmpty {
                ContentUnavailableView("Nothing declined", systemImage: "xmark.circle",
                                       description: Text("Events you can't go to show up here, in case plans change."))
            }
        }
        .navigationTitle("Declined")
        .task(id: session.dataVersion) { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }
}

#Preview {
    NavigationStack {
        DeclinedEventsView()
    }
    .mockEnvironment()
}

#Preview("Empty") {
    NavigationStack {
        DeclinedEventsView()
    }
    .mockEnvironment(signedInAs: MockPeople.ada)
}
