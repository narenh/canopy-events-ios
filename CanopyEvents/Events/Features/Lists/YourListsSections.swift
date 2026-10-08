import SwiftUI

/// Profile's "Your lists" (each opens its own screen; a name field makes
/// a new one, for verified accounts, like hosting) and, when you're on
/// any, "Lists you're on", each with Leave.
struct YourListsSections: View {
    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @State private var model = YourListsModel()
    @State private var leaving: ListMembership?

    var body: some View {
        Section("Your lists") {
            ForEach(model.lists) { list in
                NavigationLink(value: Route.ownList(list.id)) {
                    VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                        Text(list.name)
                        Text(InvitePicker.count(list.memberCount))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
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

    private func create() {
        guard model.canCreate else { return }
        Task { _ = await model.create(using: repository) }
    }
}

#Preview("Verified") {
    NavigationStack {
        Form { YourListsSections() }
            .canopyScreen()
            .navigationDestination(for: Route.self) { RouteView(route: $0) }
    }
    .mockEnvironment()
}

#Preview("Unverified") {
    NavigationStack {
        Form { YourListsSections() }
            .canopyScreen()
    }
    .mockEnvironment(signedInAs: MockPeople.sam)
}
