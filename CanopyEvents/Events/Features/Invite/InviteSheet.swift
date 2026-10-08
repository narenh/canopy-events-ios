import SwiftUI

/// A host's "Invite" (the web's invite sheet): one search field (names,
/// and a whole phone number or @username to look someone up), then your
/// lists with "Invite all <n>", "Invite everyone from…" a past event,
/// Suggested (the first eight not on the event), and everyone else A to
/// Z. People on the event stay in the list, greyed, with their status.
/// The picked gather in a tray at the foot, beside "Invite 7".
struct InviteSheet: View {
    let event: Event
    /// Called with how many were invited, after the sheet closes.
    let onInvited: (Int) -> Void

    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var model: InviteModel

    init(event: Event, me: Person.ID?, onInvited: @escaping (Int) -> Void) {
        self.event = event
        self.onInvited = onInvited
        _model = State(initialValue: InviteModel(event: event, me: me))
    }

    var body: some View {
        NavigationStack {
            List { content }
                .glassList()
                .overlay { if !model.hasLoaded { ProgressView() } }
                .alwaysShownSearch(text: $model.picker.query,
                                   prompt: session.needsVerification ? "Search by name" : "Name, phone or @username")
                .navigationTitle("Invite to \(event.title)")
                .inlineNavigationTitle()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", role: .close) { dismiss() }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    InviteTray(people: model.picker.tray, isSending: model.isSending,
                               onUnpick: { model.picker.setPicked([$0.id], false) }, onSend: send)
                }
                .task { await model.load(from: repository) }
                .task(id: model.picker.query) { await model.lookUp(using: repository) }
                .onChange(of: model.picker.selected.count) { _, count in
                    AccessibilityNotification.Announcement("\(count) picked.").post()
                }
                .errorAlert($model.errorMessage)
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder private var content: some View {
        let picker = model.picker
        let order = picker.order
        if let lookup = model.lookup, lookup.query == picker.query.trimmingCharacters(in: .whitespaces) {
            Section("Found") { found(lookup.state) }
                .glassRowBackground()
        }
        if !picker.isSearching {
            let lists = picker.lists.filter { !$0.memberIds.isEmpty }
            if !lists.isEmpty {
                Section("Your lists") {
                    ForEach(lists) { list in
                        InviteListRow(list: list, pickable: picker.pickable(in: list).count,
                                      isAllPicked: picker.isAllPicked(list)) { model.picker.toggleAll(in: list) }
                    }
                }
                .glassRowBackground()
            }
            if !model.pastEvents.isEmpty {
                Section {
                    InviteFromPastMenu(events: model.pastEvents) { past in
                        Task { await model.pickEveryone(from: past, using: repository) }
                    }
                    if let notice = model.notice {
                        Text(notice)
                            .font(.subheadline)
                            .foregroundStyle(Palette.link)
                    }
                }
                .glassRowBackground()
            }
            if !order.suggested.isEmpty {
                Section("Suggested") { rows(order.suggested) }
                    .glassRowBackground()
            }
        }
        if !order.everyone.isEmpty {
            Section(picker.isSearching ? "Matches" : order.suggested.isEmpty ? "Everyone" : "Everyone else") {
                rows(order.everyone)
            }
            .glassRowBackground()
        } else if model.hasLoaded, picker.isSearching, LookupKind(picker.query) == nil {
            quiet("No one by that name. Type a whole phone number or @username to find someone.")
        } else if model.hasLoaded, !picker.isSearching, order.suggested.isEmpty {
            quiet("No friends here yet. Type a phone number or @username to find someone, or share the link.")
        }
    }

    private func rows(_ ids: [Person.ID]) -> some View {
        ForEach(ids, id: \.self) { id in
            if let candidate = model.picker.people[id] {
                InvitePersonRow(candidate: candidate, status: model.picker.onEvent[id],
                                isPicked: model.picker.isPicked(id)) { model.picker.toggle(id) }
            }
        }
    }

    @ViewBuilder private func found(_ state: InviteLookup.State) -> some View {
        switch state {
        case .looking:
            Text("Looking…").foregroundStyle(Palette.muted)
        case .found(let id):
            rows([id])
        case .none:
            Text("No one found. Check the number or username, or share the link with them instead.")
                .foregroundStyle(Palette.muted)
        case .failed(let words):
            Text(words).foregroundStyle(Palette.danger)
        }
    }

    private func quiet(_ words: String) -> some View {
        Text(words)
            .foregroundStyle(Palette.muted)
            .listRowBackground(Color.clear)
    }

    private func send() {
        Task {
            guard let invited = await model.send(using: repository) else { return }
            dismiss()
            onInvited(invited)
        }
    }
}

#Preview("Board game night") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            InviteSheet(event: PreviewData.event(MockEvents.gameNightId), me: MockPeople.maya.id) { _ in }
        }
        .mockEnvironment()
}

#Preview("The finale: Drag Race all invited") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            InviteSheet(event: PreviewData.event(MockEvents.dragFinaleId), me: MockPeople.maya.id) { _ in }
        }
        .mockEnvironment()
}
