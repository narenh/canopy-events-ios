import SwiftUI

/// The creator's co-hosts: take one off, or make a friend one. Co-hosts
/// can edit and invite; only the creator manages co-hosts, cancels and
/// makes a new link. Changes save at once.
struct CohostsSheet: View {
    @State var event: Event
    /// Called with the event after each change, so the page can redraw.
    let onChange: (Event) -> Void

    @Environment(\.eventsRepository) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var friends: [Friend] = []
    @State private var isWorking = false
    @State private var errorMessage: String?

    private var cohosts: [Person] { event.hosts.filter { $0.role == .cohost }.map(\.person) }
    private var candidates: [Friend] {
        friends.filter { friend in !event.hosts.contains { $0.person.id == friend.id } }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Co-hosts") {
                    if cohosts.isEmpty {
                        Text("No co-hosts yet.").foregroundStyle(.secondary)
                    }
                    ForEach(cohosts) { person in
                        PersonRow(person: person) {
                            Button("Remove", role: .destructive) { run { try await repository.removeCohost(eventId: event.id, personId: person.id) } }
                                .buttonStyle(.borderless)
                        }
                    }
                }
                .glassRowBackground()
                Section("Make a friend a co-host") {
                    ForEach(candidates) { friend in
                        PersonRow(person: friend.person) {
                            Button("Add") { run { try await repository.addCohost(eventId: event.id, personId: friend.id) } }
                                .buttonStyle(.borderless)
                        }
                    }
                }
                .glassRowBackground()
            }
            .glassList()
            .disabled(isWorking)
            .navigationTitle("Co-hosts")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm) { dismiss() }
                }
            }
            .task { friends = (try? await repository.allFriends()) ?? [] }
            .errorAlert($errorMessage)
        }
    }

    private func run(_ change: @escaping () async throws -> Event) {
        Task {
            isWorking = true
            defer { isWorking = false }
            do {
                event = try await change()
                onChange(event)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    CohostsSheet(event: PreviewData.event(MockEvents.birthdayId)) { _ in }
        .mockEnvironment()
}
