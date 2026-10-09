import SwiftUI

/// The host's "Lists…" (the web's `eventListsBlock`): the lists on the
/// event, each with Take off (its owner, or the creator), then your other
/// lists, each with Add (asked first when it has people on it, since it
/// invites them), and a name field to make one, which goes on at once.
struct EventListsSheet: View {
    /// Called with the event after each change, so the page can redraw.
    let onChange: (Event) -> Void

    @Environment(\.eventsRepository) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var model: EventListsModel
    @State private var adding: OwnedList?
    @State private var takingOff: HostList?

    init(event: Event, onChange: @escaping (Event) -> Void) {
        self.onChange = onChange
        _model = State(initialValue: EventListsModel(event: event))
    }

    var body: some View {
        NavigationStack {
            List {
                if let notice = model.notice {
                    Text(notice).foregroundStyle(Palette.link).listRowBackground(Color.clear)
                }
                Section("On this event") {
                    if model.onEvent.isEmpty { Text("No lists on this event yet.").foregroundStyle(.secondary) }
                    ForEach(model.onEvent) { list in
                        EventListRow(name: list.name, detail: detail(for: list)) {
                            if list.isYours || model.event.viewer?.isCreator == true {
                                Button("Take off") { takingOff = list }
                                    .buttonStyle(.borderless)
                                    .accessibilityLabel("Take \(list.name) off")
                            }
                        }
                    }
                }
                .glassRowBackground()
                if model.isOpen { yourLists.glassRowBackground() }
            }
            .glassList()
            .disabled(model.isWorking)
            .navigationTitle("Lists")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done", role: .confirm) { dismiss() } }
            }
            .task { await model.load(from: repository) }
            .errorAlert($model.errorMessage)
            .confirmationDialog(adding.map { "Put \($0.name) on this event?" } ?? "", isPresented: isAdding,
                                titleVisibility: .visible, presenting: adding) { list in
                Button("Add") { change { await model.attach(list, using: repository) } }
            } message: { _ in
                Text("Everyone on it is invited now, and anyone who joins later too.")
            }
            .confirmationDialog(takingOff.map { "Take \($0.name) off this event?" } ?? "", isPresented: isTakingOff,
                                titleVisibility: .visible, presenting: takingOff) { list in
                Button("Take off", role: .destructive) { change { await model.detach(list, using: repository) } }
            } message: { _ in
                Text("Nobody's invitation changes; people who join later won't be invited to this one.")
            }
        }
    }

    private var yourLists: some View {
        Section("Your lists") {
            if model.myLists == nil {
                ProgressView()
            } else if model.others.isEmpty && model.onEvent.allSatisfy({ !$0.isYours }) {
                Text("You don't have any lists yet.").foregroundStyle(.secondary)
            }
            ForEach(model.others) { list in
                EventListRow(name: list.name, detail: PeoplePicker.count(list.memberCount)) {
                    Button("Add") {
                        if list.memberCount > 0 { adding = list } else { change { await model.attach(list, using: repository) } }
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Add \(list.name)")
                }
            }
            HStack {
                TextField("Name a new list", text: $model.newName)
                    .accessibilityLabel("New list name")
                    .onSubmit(create)
                Button("Create", action: create)
                    .buttonStyle(.borderless)
                    .disabled(!model.canCreate)
            }
        }
    }

    private func detail(for list: HostList) -> String {
        list.isYours ? "Your list · \(PeoplePicker.count(list.memberCount ?? 0))" : "\(list.owner.fullName)'s list"
    }

    private func create() {
        guard model.canCreate else { return }
        change { await model.create(using: repository) }
    }

    /// Runs a change; the page redraws, and VoiceOver hears the notice.
    private func change(_ run: @escaping () async -> Event?) {
        Task {
            guard let event = await run() else { return }
            onChange(event)
            if let notice = model.notice { AccessibilityNotification.Announcement(notice).post() }
        }
    }

    private var isAdding: Binding<Bool> {
        Binding(get: { adding != nil }, set: { if !$0 { adding = nil } })
    }

    private var isTakingOff: Binding<Bool> {
        Binding(get: { takingOff != nil }, set: { if !$0 { takingOff = nil } })
    }
}

#Preview("Board game night") {
    EventListsSheet(event: PreviewData.event(MockEvents.gameNightId)) { _ in }
        .mockEnvironment()
}

#Preview("The finale, Drag Race on it") {
    EventListsSheet(event: PreviewData.event(MockEvents.dragFinaleId)) { _ in }
        .mockEnvironment()
}
