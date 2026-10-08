import SwiftUI

/// The event page: cover and title, when and where, your RSVP (or host
/// tools), friends going, a peek at the guest list and the wall.
struct EventDetailView: View {
    @Environment(\.eventsRepository) private var repository
    @State private var model: EventDetailModel
    /// Set to open the RSVP sheet preset to that answer.
    @State private var answeringWithGuests: RSVPStatus?
    @State private var isEditing = false
    @State private var isInviting = false

    init(eventId: Event.ID) {
        _model = State(initialValue: EventDetailModel(eventId: eventId))
    }

    var body: some View {
        Group {
            if let event = model.event {
                content(for: event)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .canopyScreen()
    }

    private func content(for event: Event) -> some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                EventHeroView(event: event)
                Group {
                    EventInfoSection(event: event)
                    if event.viewer?.isHost == true {
                        HostToolsSection(event: event, onInvite: { isInviting = true }, onEdit: { isEditing = true })
                    } else {
                        YourRSVPSection(
                            event: event,
                            isSaving: model.isSaving,
                            onAnswer: { status in Task { await model.answer(status, using: repository) } },
                            onAnswerWithGuests: { answeringWithGuests = $0 }
                        )
                    }
                    HostsSection(hosts: event.hosts)
                    if let friendsGoing = event.friendsGoing, friendsGoing.count > 0 {
                        FriendsGoingSection(friendsGoing: friendsGoing)
                    }
                    GuestListPreviewSection(event: event, guestList: model.guestList)
                    WallPreviewSection(eventId: event.id, entries: model.latestEntries, isVisible: model.wallVisible)
                }
                .padding(.horizontal, Spacing.large)
            }
            .padding(.bottom, Spacing.xxLarge)
        }
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ShareLink(item: event.url, subject: Text(event.title))
        }
        .sheet(item: $answeringWithGuests) { status in
            RSVPSheet(event: event, status: status) { status, guests in
                Task { await model.answer(status, guests: guests, using: repository) }
            }
        }
        .sheet(isPresented: $isEditing) {
            EventEditorView(event: event) { _ in
                Task { await model.load(from: repository) }
            }
        }
        .sheet(isPresented: $isInviting) {
            InviteFriendsSheet(eventId: event.id) {
                Task { await model.load(from: repository) }
            }
        }
    }
}

#Preview("Going, plus-ones allowed") {
    NavigationStack { EventDetailView(eventId: MockEvents.rooftopId) }
        .mockEnvironment()
}

#Preview("Hosting, co-hosted") {
    NavigationStack { EventDetailView(eventId: MockEvents.birthdayId) }
        .mockEnvironment()
}

#Preview("Waitlisted") {
    NavigationStack { EventDetailView(eventId: MockEvents.supperClubId) }
        .mockEnvironment()
}

#Preview("Invited, hidden guest list") {
    NavigationStack { EventDetailView(eventId: MockEvents.hikeId) }
        .mockEnvironment()
}

#Preview("Cancelled") {
    NavigationStack { EventDetailView(eventId: MockEvents.karaokeId) }
        .mockEnvironment()
}
