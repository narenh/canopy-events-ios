import SwiftUI

/// One of your lists: its name and count, Share link and Show QR (big,
/// for the door), the link, then who's on it, newest first, each with
/// when they joined; swipe to take someone off. Rename, Reset link and
/// Delete are in the ⋯ menu.
struct OwnListView: View {
    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var model: OwnListModel
    @State private var showsQR = false
    @State private var renaming: String?
    @State private var pending: OwnListAction?

    init(listId: OwnedList.ID) {
        _model = State(initialValue: OwnListModel(listId: listId))
    }

    var body: some View {
        Group {
            if let list = model.list {
                content(for: list)
            } else {
                ProgressView()
            }
        }
        .task { await model.load(from: repository) }
        .onChange(of: model.isGone) { _, gone in
            if gone { session.dataChanged(); dismiss() }
        }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }

    private func content(for list: OwnedList) -> some View {
        List {
            Section {
                OwnListHeader(list: list) { showsQR = true }
            }
            .listRowBackground(Color.clear)
            Section {
                if model.members.isEmpty {
                    Text("Share the link or show the QR code, and people who join show up here.")
                        .foregroundStyle(Palette.muted)
                }
                ForEach(model.members) { member in
                    PersonRow(person: member.person, detail: JoinedDate.string(for: member.joinedAt))
                        .accessibilityElement(children: .combine)
                        .swipeActions {
                            Button("Remove", systemImage: "person.badge.minus", role: .destructive) {
                                pending = .remove(member)
                            }
                        }
                        .accessibilityAction(named: "Remove") { pending = .remove(member) }
                }
            } header: {
                Text(list.memberCount > 0 ? "People · \(list.memberCount)" : "People")
            }
            .glassRowBackground()
        }
        .navigationTitle(list.name)
        .inlineNavigationTitle()
        .toolbar { menu(for: list) }
        .sheet(isPresented: $showsQR) { ListQRSheet(lists: [ListQRItem(list)]) }
        .alert("Rename list", isPresented: isRenaming) {
            TextField("List name", text: Binding(get: { renaming ?? "" }, set: { renaming = $0 }))
            Button("Save") {
                let name = renaming ?? ""
                Task { await model.rename(to: name, using: repository); session.dataChanged() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(pending?.title(list: list.name) ?? "", isPresented: isConfirming,
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
    NavigationStack { OwnListView(listId: MockLists.dragRaceId) }
        .mockEnvironment()
}
