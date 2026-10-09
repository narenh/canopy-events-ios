import SwiftUI

/// One of your lists, in a sheet (the web's `listSheet`): the link with
/// Share, Copy and QR; Rename, Reset link and Delete in the ⋯ menu; then
/// its people with Add people and a name search. Add people is a step
/// pushed inside the sheet (`ListAddView`), which comes back here saying
/// what happened. Its picker lasts while the sheet is open.
struct ListSheet: View {
    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var model: OwnListModel
    @State private var showsQR: Bool
    @State private var addsPeople = false
    @State private var adder: PeoplePickerModel?
    @State private var renaming: String?
    @State private var pending: OwnListAction?

    /// `showsQR` opens it with the QR code showing (a list just made).
    init(listId: OwnedList.ID, showsQR: Bool = false) {
        _model = State(initialValue: OwnListModel(listId: listId))
        _showsQR = State(initialValue: showsQR)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let list = model.list {
                    ListSheetList(list: list, model: model, showsQR: $showsQR,
                                  onAdd: { openAdd(list) }, onRemove: { pending = .remove($0) })
                } else {
                    ProgressView()
                }
            }
            .peopleSheetTitle(model.list?.name ?? "List")
            .toolbar { if let list = model.list { menu(for: list) } }
            .navigationDestination(isPresented: $addsPeople) {
                if let adder, let list = model.list {
                    ListAddView(listName: list.name, model: adder, onAdded: added)
                }
            }
        }
        .task {
            await model.load(from: repository)
            if LaunchOptions.addsToOpenList, let list = model.list {
                LaunchOptions.addsToOpenList = false
                openAdd(list)
            }
        }
        .onChange(of: model.isGone) { _, gone in
            if gone { session.dataChanged(); dismiss() }
        }
        .errorAlert($model.errorMessage)
        .alert("Rename list", isPresented: isRenaming) {
            TextField("List name", text: Binding(get: { renaming ?? "" }, set: { renaming = $0 }))
            Button("Save") {
                let name = renaming ?? ""
                Task { await model.rename(to: name, using: repository); session.dataChanged() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(pending?.title(list: model.list?.name ?? "") ?? "", isPresented: isConfirming,
                            titleVisibility: .visible, presenting: pending) { action in
            Button(action.confirmLabel, role: .destructive) { Task { await run(action) } }
        } message: { action in
            Text(action.message)
        }
    }

    private func menu(for list: OwnedList) -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button("Rename…", systemImage: "pencil") { renaming = list.name }
                Button("Reset link…", systemImage: "arrow.clockwise") { pending = .resetLink }
                Section {
                    Button("Delete list…", systemImage: "trash", role: .destructive) { pending = .delete }
                }
            } label: {
                Label("More actions", systemImage: "ellipsis")
            }
        }
    }

    private func openAdd(_ list: OwnedList) {
        if adder == nil { adder = PeoplePickerModel(target: .list(list), me: session.me?.id) }
        model.notice = nil
        addsPeople = true
    }

    /// Back on the list, fetched again, saying what happened.
    private func added(_ words: String) {
        addsPeople = false
        model.notice = words
        AccessibilityNotification.Announcement(words).post()
        Task {
            await model.load(from: repository)
            session.dataChanged()
        }
    }

    private func run(_ action: OwnListAction) async {
        switch action {
        case .resetLink: await model.resetLink(using: repository)
        case .delete: await model.delete(using: repository)
        case .remove(let member): await model.remove(member, using: repository)
        }
        session.dataChanged()
    }

    private var isRenaming: Binding<Bool> {
        Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })
    }

    private var isConfirming: Binding<Bool> {
        Binding(get: { pending != nil }, set: { if !$0 { pending = nil } })
    }
}

#Preview("Drag Race") {
    Color.clear
        .sheet(isPresented: .constant(true)) { ListSheet(listId: MockLists.dragRaceId) }
        .mockEnvironment()
}

#Preview("New, with its QR code") {
    Color.clear
        .sheet(isPresented: .constant(true)) { ListSheet(listId: MockLists.climbingId, showsQR: true) }
        .mockEnvironment()
}
