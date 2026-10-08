import SwiftUI

/// The Invites tab: events you've been invited to and haven't answered.
/// Answering from a card moves the event out (going and maybe go to
/// Events). "Declined" lists the ones you said you can't go to.
struct InvitesView: View {
    @Environment(\.eventsRepository) private var repository
    @State private var model = EventListModel(.invitations)

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.large) {
                ListLink(title: "Declined", systemImage: "xmark.circle", route: .declinedEvents)

                ForEach(model.events) { event in
                    InviteCard(event: event) { status in
                        Task { await model.answer(event, with: status, using: repository) }
                    }
                }
            }
            .padding(Spacing.large)
            .animation(.default, value: model.events)
        }
        .overlay { emptyState }
        .navigationTitle("Invites")
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
                "No invites",
                systemImage: "envelope.open",
                description: Text("When friends invite you to something, it shows up here.")
            )
        }
    }
}

#Preview {
    NavigationStack {
        InvitesView()
    }
    .mockEnvironment()
}

#Preview("Empty") {
    NavigationStack {
        InvitesView()
    }
    .mockEnvironment(signedInAs: MockPeople.ada)
}
