import SwiftUI

/// The full guest list, grouped by status with counts. Respects the
/// host's visibility choice: when names are hidden, only counts show.
struct GuestListView: View {
    @Environment(\.eventsRepository) private var repository
    @State private var model: GuestListModel

    init(eventId: Event.ID) {
        _model = State(initialValue: GuestListModel(eventId: eventId))
    }

    var body: some View {
        Group {
            if let guestList = model.guestList {
                if guestList.guestsVisible {
                    list(guestList)
                } else {
                    HiddenGuestListView(counts: guestList.counts)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Guest list")
        .inlineNavigationTitle()
        .task { await model.load(from: repository) }
        .refreshable { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }

    private func list(_ guestList: GuestList) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.large) {
                ForEach(GuestListModel.sectionOrder) { status in
                    let guests = guestList.guests(with: status)
                    if !guests.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.medium) {
                            SectionHeader(title: status.title, count: guests.count)
                            ForEach(guests) { guest in
                                if guest.id != guests.first?.id { Divider() }
                                GuestRow(guest: guest)
                            }
                        }
                        .glassCard()
                    }
                }
            }
            .padding(Spacing.large)
        }
        .overlay {
            if guestList.guests.isEmpty {
                ContentUnavailableView("No one yet", systemImage: "person.2",
                                       description: Text("Nobody has answered so far."))
            }
        }
    }
}

#Preview("Visible") {
    NavigationStack { GuestListView(eventId: MockEvents.rooftopId) }
        .mockEnvironment()
}

#Preview("Host sees invited and waitlist") {
    NavigationStack { GuestListView(eventId: MockEvents.gameNightId) }
        .mockEnvironment()
}

#Preview("Hidden until you RSVP") {
    NavigationStack { GuestListView(eventId: MockEvents.hikeId) }
        .mockEnvironment()
}
