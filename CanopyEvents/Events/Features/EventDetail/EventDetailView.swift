import SwiftUI

/// The event page, after the web's: the cover hero edge to edge (in a
/// column with rounded top corners on iPad), the title and when on its
/// fade, the place, hosts and description with no card around them, then
/// your RSVP (or the host's controls), Attending and the wall, all on the
/// event's own colours.
struct EventDetailView: View {
    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var model: EventDetailModel
    /// Set to open the RSVP sheet preset to that answer.
    @State private var answeringWithGuests: RSVPStatus?
    @State private var isEditing = false
    @State private var isInviting = false
    @State private var isManagingCohosts = false
    @State private var pendingAction: HostAction?
    /// Wider than a phone: the page becomes a column and the hero is inset.
    @State private var isWide = false
    @State private var heroWidth: CGFloat = 0
    /// How far the page is pulled down past its top: the picture stays put.
    @State private var overscroll: CGFloat = 0

    init(eventId: Event.ID) {
        _model = State(initialValue: EventDetailModel(eventId: eventId))
        _isEditing = State(initialValue: LaunchOptions.editsOpenEvent && LaunchOptions.openEventId == eventId)
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
        .task(id: session.dataVersion) { await model.load(from: repository) }
        .errorAlert($model.errorMessage)
        .eventAccent(model.event?.theme ?? .canopyGreen)
        .canopyScreen(theme: model.event?.theme ?? .canopyGreen)
    }

    private func content(for event: Event) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                EventHeroView(event: event, isInset: isWide, overscroll: overscroll)
                    .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { heroWidth = $0 }
                // The title starts on the band: the last sixth of the width.
                VStack(alignment: .leading, spacing: Spacing.xLarge) {
                    EventHeadView(event: event)
                    EventInfoSection(event: event)
                }
                .padding(.horizontal, isWide ? Spacing.xLarge : Spacing.large)
                .padding(.top, -heroWidth / 6)
                VStack(spacing: Spacing.large) {
                    sections(for: event)
                }
                .padding(.horizontal, isWide ? 0 : Spacing.large)
                .padding(.top, Spacing.xxLarge)
            }
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
            .padding(.top, isWide ? Spacing.large : 0)
            .padding(.bottom, Spacing.xxLarge)
        }
        .trackingOverscroll($overscroll)
        .onGeometryChange(for: Bool.self) { $0.size.width >= 700 } action: { isWide = $0 }
        .ignoresSafeArea(edges: isWide ? [] : .top)
        .toolbar {
            ShareLink(item: event.url, subject: Text(event.title))
        }
        .sheet(item: $answeringWithGuests) { status in
            RSVPSheet(event: event, status: status) { status, guests in
                Task { await model.answer(status, guests: guests, using: repository) }
            }
            .eventAccent(event.theme)
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
        .sheet(isPresented: $isManagingCohosts) {
            CohostsSheet(event: event) { model.update($0) }
        }
        .confirmationDialog(pendingAction?.title ?? "", isPresented: isConfirming, titleVisibility: .visible,
                            presenting: pendingAction) { action in
            Button(action.confirmLabel, role: action.isDestructive ? .destructive : nil) {
                Task { await run(action) }
            }
        } message: { action in
            Text(action.message(for: event))
        }
    }

    @ViewBuilder private func sections(for event: Event) -> some View {
        if event.viewer?.isHost == true {
            HostControlsSection(
                event: event, notice: model.hostNotice,
                onInvite: { isInviting = true }, onEdit: { isEditing = true },
                onCohosts: { isManagingCohosts = true }, onAction: { pendingAction = $0 }
            )
        } else {
            YourRSVPSection(
                event: event,
                isSaving: model.isSaving,
                onAnswer: { status in Task { await model.answer(status, using: repository) } },
                onAnswerWithGuests: { answeringWithGuests = $0 }
            )
        }
        if event.myStatus != .removed {
            AttendingSection(event: event, guestList: model.guestList)
            WallPreviewSection(eventId: event.id, entries: model.latestEntries, isVisible: model.wallVisible)
        }
    }

    private var isConfirming: Binding<Bool> {
        Binding(get: { pendingAction != nil }, set: { if !$0 { pendingAction = nil } })
    }

    private func run(_ action: HostAction) async {
        if await model.perform(action, me: session.me?.id, using: repository) {
            dismiss()
        }
    }
}

#Preview("Going, plus-ones allowed") {
    NavigationStack { EventDetailView(eventId: MockEvents.rooftopId) }
        .mockEnvironment()
}

#Preview("Hosting, no cover, purple") {
    NavigationStack { EventDetailView(eventId: MockEvents.gameNightId) }
        .mockEnvironment()
}

#Preview("Long title, grey") {
    NavigationStack { EventDetailView(eventId: MockEvents.galleryId) }
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
