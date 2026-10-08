import SwiftUI

/// The host's "Lists…" (the web's `eventListsBlock`): the lists on the
/// event, each with Take off (its owner, or the creator), then your other
/// lists, each with Add (asked first when it has people on it, since it
/// invites them), and a name field to make one, which goes on at once.
/// Changes save straight away.
struct EventListsSheet: View {
    @State var event: Event
    /// Called with the event after each change, so the page can redraw.
    let onChange: (Event) -> Void

    @Environment(\.eventsRepository) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var myLists: [OwnedList]?
    @State private var newName = ""
    @State private var notice: String?
    @State private var adding: OwnedList?
    @State private var takingOff: HostList?
    @State private var isWorking = false
    @State private var errorMessage: String?

    private var onEvent: [HostList] { event.hostLists ?? [] }
    private var others: [OwnedList] { (myLists ?? []).filter { list in !onEvent.contains { $0.id == list.id } } }
    private var isOpen: Bool { EventPhase(event: event).isOpen }

    var body: some View {
        NavigationStack {
            List {
                if let notice {
                    Text(notice)
                        .foregroundStyle(Palette.link)
                        .listRowBackground(Color.clear)
                }
                Section("On this event") {
                    if onEvent.isEmpty {
                        Text("No lists on this event yet.").foregroundStyle(.secondary)
                    }
                    ForEach(onEvent) { list in
                        EventListRow(name: list.name, detail: detail(for: list)) {
                            if list.isYours || event.viewer?.isCreator == true {
                                Button("Take off") { takingOff = list }
                                    .buttonStyle(.borderless)
                                    .accessibilityLabel("Take \(list.name) off")
                            }
                        }
                    }
                }
                .glassRowBackground()
                if isOpen {
                    Section("Your lists") {
                        if myLists == nil {
                            ProgressView()
                        } else if others.isEmpty && onEvent.allSatisfy({ !$0.isYours }) {
                            Text("You don't have any lists yet.").foregroundStyle(.secondary)
                        }
                        ForEach(others) { list in
                            EventListRow(name: list.name, detail: InvitePicker.count(list.memberCount)) {
                                Button("Add") {
                                    if list.memberCount > 0 { adding = list } else { attach(list) }
                                }
                                    .buttonStyle(.borderless)
                                    .accessibilityLabel("Add \(list.name)")
                            }
                        }
                        HStack {
                            TextField("Name a new list", text: $newName)
                                .accessibilityLabel("New list name")
                                .onSubmit(create)
                            Button("Create", action: create)
                                .buttonStyle(.borderless)
                                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .glassRowBackground()
                }
            }
            .glassList()
            .disabled(isWorking)
            .navigationTitle("Lists")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm) { dismiss() }
                }
            }
            .task { myLists = (try? await repository.lists()) ?? [] }
            .errorAlert($errorMessage)
            .confirmationDialog(adding.map { "Put \($0.name) on this event?" } ?? "", isPresented: isAdding,
                                titleVisibility: .visible, presenting: adding) { list in
                Button("Add") { attach(list) }
            } message: { _ in
                Text("Everyone on it is invited now, and anyone who joins later too.")
            }
            .confirmationDialog(takingOff.map { "Take \($0.name) off this event?" } ?? "", isPresented: isTakingOff,
                                titleVisibility: .visible, presenting: takingOff) { list in
                Button("Take off", role: .destructive) { detach(list) }
            } message: { _ in
                Text("Nobody's invitation changes; people who join later won't be invited to this one.")
            }
        }
    }

    private func detail(for list: HostList) -> String {
        list.isYours ? "Your list · \(InvitePicker.count(list.memberCount ?? 0))" : "\(list.owner.fullName)'s list"
    }

    private func attach(_ list: OwnedList) {
        run {
            let attached = try await repository.attachList(eventId: event.id, listId: list.id)
            notice = switch attached.invitedCount {
            case 0: "\(list.name) is on this event."
            case 1: "Invited 1 from \(list.name)."
            default: "Invited \(attached.invitedCount) from \(list.name)."
            }
            return attached.event
        }
    }

    private func detach(_ list: HostList) {
        run {
            notice = nil
            return try await repository.detachList(eventId: event.id, listId: list.id)
        }
    }

    /// Makes a list and puts it on at once (it has nobody on it to invite).
    private func create() {
        let name = newName
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        run {
            let list = try await repository.createList(name: name)
            newName = ""
            myLists?.append(list)
            notice = "\(list.name) is on this event."
            return try await repository.attachList(eventId: event.id, listId: list.id).event
        }
    }

    private func run(_ change: @escaping () async throws -> Event) {
        Task {
            isWorking = true
            defer { isWorking = false }
            do {
                event = try await change()
                onChange(event)
                if let notice { AccessibilityNotification.Announcement(notice).post() }
            } catch {
                errorMessage = error.localizedDescription
            }
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
