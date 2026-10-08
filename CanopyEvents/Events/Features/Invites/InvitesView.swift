import SwiftUI

/// The Invites tab: events you've been invited to and haven't answered,
/// with the answer buttons on each card; then, under "Declined", the
/// upcoming events you said you can't go to, each with just Going to
/// change your mind (an answer changes, never goes back). As the web's
/// Invited tab.
struct InvitesView: View {
    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @State private var invitations = EventListModel(.invitations)
    @State private var declined = EventListModel(.declined)

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.large) {
                ForEach(invitations.events) { event in
                    InviteCard(event: event) { status in Task { await answer(event, status) } }
                }
                if !declined.events.isEmpty {
                    Text("Declined")
                        .font(Typography.sectionTitle)
                        .padding(.top, invitations.events.isEmpty ? 0 : Spacing.medium)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(declined.events) { event in
                        InviteCard(event: event, answers: [.going]) { status in Task { await answer(event, status) } }
                    }
                }
            }
            .padding(Spacing.large)
            .animation(.default, value: invitations.events + declined.events)
        }
        .overlay { emptyState }
        .navigationTitle("Invites")
        .task(id: session.dataVersion) { await load() }
        .refreshable { await load() }
        .errorAlert(Binding(get: { invitations.errorMessage ?? declined.errorMessage },
                            set: { invitations.errorMessage = $0; declined.errorMessage = $0 }))
        .canopyScreen()
    }

    private func load() async {
        async let first: Void = invitations.load(from: repository)
        async let second: Void = declined.load(from: repository)
        _ = await (first, second)
    }

    /// An answer can move a card between the two lists: reload both.
    private func answer(_ event: Event, _ status: RSVPStatus) async {
        await invitations.answer(event, with: status, using: repository)
        await declined.load(from: repository)
    }

    @ViewBuilder private var emptyState: some View {
        if !invitations.hasLoaded || !declined.hasLoaded {
            ProgressView()
        } else if invitations.events.isEmpty && declined.events.isEmpty {
            ContentUnavailableView(
                "No invitations right now",
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
