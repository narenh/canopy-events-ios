import SwiftUI

/// "View all" (the web's guests sheet): a name search, a tab for each
/// status there's anyone in with its count in its color, then the chosen
/// tab's count and plus-ones and its people; searching covers every tab.
/// It shows exactly what the guest list gives you, so never more than the
/// page. Hosts also get Remove (asked first), the Removed tab with Undo,
/// and Invite, which closes this sheet for the invite sheet.
struct GuestsSheet: View {
    let event: Event
    /// After a host's change, so the page can fetch itself again.
    let onChange: () -> Void
    /// Invite: this sheet closes, and the page opens the invite sheet.
    /// Nil hides it (guests, and an event that can't take invitations).
    var onInvite: (() -> Void)?

    @Environment(\.eventsRepository) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var model: GuestsModel
    @State private var removing: Guest?

    init(event: Event, onChange: @escaping () -> Void, onInvite: (() -> Void)? = nil) {
        self.event = event
        self.onChange = onChange
        self.onInvite = onInvite
        _model = State(initialValue: GuestsModel(event: event))
    }

    var body: some View {
        NavigationStack {
            content
                .peopleSheetTitle("Guests")
                .alwaysShownSearch(text: $model.query, prompt: "Search by name")
                .safeAreaInset(edge: .bottom, spacing: 0) { inviteBar }
        }
        .presentationDetents([.medium, .large])
        .task { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .confirmationDialog(removing.map { "Remove \($0.person.fullName) from this event?" } ?? "",
                            isPresented: isConfirming, titleVisibility: .visible, presenting: removing) { guest in
            Button("Remove", role: .destructive) { change { await model.remove(guest, using: repository) } }
        } message: { _ in
            Text("They won't be able to answer, or see the address, the guest list or the updates. You can undo this.")
        }
    }

    @ViewBuilder private var content: some View {
        if model.guestsVisible == false {
            HiddenGuestListView(counts: event.counts)
        } else if model.tabs != nil {
            GuestsList(model: model, onRemove: { removing = $0 },
                       onUndo: { guest in change { await model.restore(guest, using: repository) } })
        } else {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder private var inviteBar: some View {
        if model.isHost, let onInvite {
            Button {
                dismiss()
                onInvite()
            } label: {
                Label("Invite", systemImage: "person.badge.plus")
                    .font(Typography.button)
                    .frame(maxWidth: .infinity)
            }
            .accentProminentButtonStyle()
            .controlSize(.large)
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.small)
            .background(.bar)
        }
    }

    /// Runs a host's change; the sheet and the page are fetched again.
    private func change(_ run: @escaping () async -> Bool) {
        Task {
            if await run() { onChange() }
            if let notice = model.notice { AccessibilityNotification.Announcement(notice).post() }
        }
    }

    private var isConfirming: Binding<Bool> {
        Binding(get: { removing != nil }, set: { if !$0 { removing = nil } })
    }
}

#Preview("Host: every status") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            GuestsSheet(event: PreviewData.event(MockEvents.gameNightId), onChange: {}, onInvite: {})
                .eventAccent(PreviewData.event(MockEvents.gameNightId).accent)
        }
        .mockEnvironment()
}

#Preview("Guest") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            GuestsSheet(event: PreviewData.event(MockEvents.rooftopId), onChange: {})
        }
        .mockEnvironment()
}
