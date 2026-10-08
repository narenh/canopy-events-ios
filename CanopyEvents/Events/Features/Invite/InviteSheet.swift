import SwiftUI

/// A host's "Invite" (the web's invite sheet): one search field (names,
/// and a whole phone number or @username to look someone up), "Filter by
/// past event" under it, then your lists with "Invite all <n>", Suggested
/// (the first eight not on the event), and everyone else A to Z. Filtered,
/// it's just that event's people, and typing searches within them. People
/// on the event stay in the list, greyed, with their status. The picked
/// gather in a tray at the foot, beside "Invite 7".
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
        if !model.pastEvents.isEmpty {
            Section {
                InviteFromPastMenu(events: model.pastEvents, selection: fromSelection)
            }
            .glassRowBackground()
        }
        if let lookup = model.lookup, lookup.query == picker.query.trimmingCharacters(in: .whitespaces) {
            Section("Found") { found(lookup.state) }
                .glassRowBackground()
        }
        if let from = picker.from, from.isHidden {
            quiet(InvitePicker.hidden(from.title))
        } else {
            people
        }
    }

    @ViewBuilder private var people: some View {
        let picker = model.picker
        let order = picker.order
        if !picker.isSearching, picker.from == nil {
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
            if !order.suggested.isEmpty {
                Section("Suggested") { rows(order.suggested) }
                    .glassRowBackground()
            }
        }
        if !order.everyone.isEmpty {
            Section(heading(suggested: !order.suggested.isEmpty)) { rows(order.everyone) }
                .glassRowBackground()
        } else if model.hasLoaded, picker.isSearching, LookupKind(picker.query) == nil {
            quiet("No one by that name. Type a whole phone number or @username to find someone.")
        } else if let from = picker.from, !picker.isSearching {
            quiet(InvitePicker.empty(from.title))
        } else if model.hasLoaded, !picker.isSearching, order.suggested.isEmpty {
            quiet("No friends here yet. Type a phone number or @username to find someone, or share the link.")
        }
    }

    private func heading(suggested: Bool) -> String {
        if model.picker.isSearching { return "Matches" }
        if let from = model.picker.from { return "From \(from.title)" }
        return suggested ? "Everyone else" : "Everyone"
    }

    /// The menu shows the choice at once; the list narrows once that
    /// event's people are in, and VoiceOver hears how many.
    private var fromSelection: Binding<Event.ID?> {
        Binding(get: { model.fromId }, set: { id in
            Task {
                if let words = await model.filter(by: id, using: repository) {
                    AccessibilityNotification.Announcement(words).post()
                }
            }
        })
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
