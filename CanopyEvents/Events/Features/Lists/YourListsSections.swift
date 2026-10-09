import SwiftUI

/// Profile's "Your lists", a row each (its name, how many, a chevron)
/// that opens the list's sheet, and a name field that makes a new one
/// (for verified accounts, like hosting) and opens it with its QR code
/// showing; then, when you're on any, "Lists you're on", each with Leave.
struct YourListsSections: View {
    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @State private var model = YourListsModel()
    @State private var leaving: ListMembership?
    /// The list whose sheet is open. Profile holds it and shows the
    /// sheet, outside the form, which is made afresh when your profile
    /// changes and would take an open sheet with it.
    @Binding var opened: OpenedList?

    var body: some View {
        Section("Your lists") {
            ForEach(model.lists) { list in
                Button { opened = OpenedList(id: list.id) } label: { row(list) }
            }
            if session.needsVerification {
                Text("Confirm your email to make lists.")
                    .foregroundStyle(Palette.muted)
            } else {
                HStack {
                    TextField("Name a new list", text: $model.newName)
                        .accessibilityLabel("New list name")
                        .submitLabel(.done)
                        .onSubmit(create)
                    Button("Create", action: create)
                        .buttonStyle(.borderless)
                        .disabled(!model.canCreate)
                }
            }
        }
        .glassRowBackground()
        .task(id: session.dataVersion) { await model.load(from: repository) }
        .errorAlert($model.errorMessage)

        if !model.memberships.isEmpty {
            Section("Lists you're on") {
                ForEach(model.memberships) { membership in
                    ListMembershipRow(membership: membership) { leaving = membership }
                }
            }
            .glassRowBackground()
            .confirmationDialog(leaving.map { "Leave \($0.name)?" } ?? "", isPresented: isConfirmingLeave,
                                titleVisibility: .visible, presenting: leaving) { membership in
                Button("Leave", role: .destructive) { Task { await model.leave(membership, using: repository) } }
            } message: { membership in
                Text("\(membership.owner.firstName) won't be told, and you won't be invited to its events any more.")
            }
        }
    }

    private var isConfirmingLeave: Binding<Bool> {
        Binding(get: { leaving != nil }, set: { if !$0 { leaving = nil } })
    }

    private func row(_ list: OwnedList) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(list.name)
                    .foregroundStyle(Color.primary)
                Text(PeoplePicker.count(list.memberCount))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            Spacer(minLength: Spacing.small)
            Image(systemName: "chevron.forward")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Palette.muted)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    /// Makes the list and opens it, with its QR code showing: the next
    /// thing anyone does with a new list.
    private func create() {
        guard model.canCreate else { return }
        Task {
            if let list = await model.create(using: repository) { opened = OpenedList(id: list.id, showsQR: true) }
        }
    }
}

#Preview("Verified") {
    @Previewable @State var opened: OpenedList?
    NavigationStack {
        Form { YourListsSections(opened: $opened) }
            .canopyScreen()
            .sheet(item: $opened) { ListSheet(listId: $0.id, showsQR: $0.showsQR) }
    }
    .mockEnvironment()
}

#Preview("Unverified") {
    NavigationStack {
        Form { YourListsSections(opened: .constant(nil)) }
            .canopyScreen()
    }
    .mockEnvironment(signedInAs: MockPeople.sam)
}
