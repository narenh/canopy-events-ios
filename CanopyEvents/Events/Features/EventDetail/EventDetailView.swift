import SwiftUI

/// The event page, after the web's: the cover hero edge to edge (in a
/// column with rounded top corners on iPad), the title and when on its
/// fade, the place, hosts and description with no card around them, then
/// your RSVP (or the host's controls), Attending and the wall, all on the
/// event's own colors.
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
    @State private var isManagingLists = false
    @State private var showsListQR = false
    /// A list from "Get invited next time", while asking first.
    @State private var joining: JoinableList?
    @State private var pendingAction: HostAction?
    @State private var confirmsLeave = false
    /// Wider than a phone: the page becomes a column and the hero is inset.
    @State private var isWide = false
    @State private var heroWidth: CGFloat = 0
    /// How far the page is pulled down past its top: the picture stays put.
    @State private var overscroll: CGFloat = 0

    /// `-mockDuplicate YES`: open the duplicate editor once loaded.
    @State private var launchesDuplicate: Bool

    /// `showsLists` opens Lists… at once (a copy just made from an event
    /// that had your lists on it).
    init(eventId: Event.ID, showsLists: Bool = false) {
        _model = State(initialValue: EventDetailModel(eventId: eventId))
        _isEditing = State(initialValue: LaunchOptions.editsOpenEvent && LaunchOptions.openEventId == eventId)
        _isInviting = State(initialValue: LaunchOptions.invitesOpenEvent && LaunchOptions.openEventId == eventId)
        _isManagingLists = State(initialValue: showsLists)
        _launchesDuplicate = State(initialValue: LaunchOptions.duplicatesOpenEvent && LaunchOptions.openEventId == eventId)
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
        .task(id: session.dataVersion) {
            await model.load(from: repository)
            if launchesDuplicate {
                launchesDuplicate = false
                await model.duplicate(using: repository)
            }
        }
        .duplicating($model.duplicating)
        .errorAlert($model.errorMessage)
        .eventAccent(model.event?.accent ?? .canopyGreen)
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
            .eventAccent(event.accent)
        }
        .sheet(isPresented: $isEditing) {
            EventEditorView(event: event) { _ in
                Task { await model.load(from: repository) }
            }
        }
        .sheet(isPresented: $isInviting) {
            InviteSheet(event: event, me: session.me?.id) { count in
                Task { await model.invited(count, using: repository) }
            }
            .eventAccent(event.accent)
        }
        .sheet(isPresented: $isManagingCohosts) {
            CohostsSheet(event: event) { model.update($0) }
        }
        .sheet(isPresented: $isManagingLists) {
            EventListsSheet(event: event) { model.update($0) }
                .eventAccent(event.accent)
        }
        .sheet(isPresented: $showsListQR) {
            ListQRSheet(lists: (event.hostLists ?? []).map(ListQRItem.init))
        }
        .confirmationDialog(joining.map { "Join \($0.owner.firstName)'s \($0.name)?" } ?? "", isPresented: isConfirmingJoin,
                            titleVisibility: .visible, presenting: joining) { list in
            Button("Join") { Task { await model.joinList(list, using: repository) } }
        } message: { list in
            Text("\(list.owner.firstName) will be able to invite you to events.")
        }
        .onChange(of: model.hostNotice) { _, notice in
            if let notice { AccessibilityNotification.Announcement(notice).post() }
        }
        .confirmationDialog(pendingAction?.title ?? "", isPresented: isConfirming, titleVisibility: .visible,
                            presenting: pendingAction) { action in
            Button(action.confirmLabel, role: action.isDestructive ? .destructive : nil) {
                Task { await run(action) }
            }
        } message: { action in
            Text(action.message(for: event))
        }
        .confirmationDialog(GuestAction.leave.title, isPresented: $confirmsLeave, titleVisibility: .visible) {
            Button(GuestAction.leave.confirmLabel, role: .destructive) {
                Task { await model.leave(using: repository) }
            }
        } message: {
            Text(GuestAction.leave.message)
        }
    }

    @ViewBuilder private func sections(for event: Event) -> some View {
        if event.viewer?.isHost == true {
            HostControlsSection(
                event: event, notice: model.hostNotice,
                onInvite: { isInviting = true }, onEdit: { isEditing = true },
                onCohosts: { isManagingCohosts = true }, onLists: { isManagingLists = true },
                onShowListQR: { showsListQR = true },
                onDuplicate: session.needsVerification ? nil : { Task { await model.duplicate(using: repository) } },
                onAction: { pendingAction = $0 }
            )
        } else {
            YourRSVPSection(
                event: event,
                isSaving: model.isSaving,
                onAnswer: { status in Task { await model.answer(status, using: repository) } },
                onAnswerWithGuests: { answeringWithGuests = $0 },
                menu: guestMenu(for: event)
            )
            if event.joinableList != nil || model.joinedList != nil {
                JoinListSection(list: model.joinedList == nil ? event.joinableList : nil, joined: model.joinedList,
                                isJoining: model.isSaving) { joining = $0 }
            }
        }
        if event.myStatus != .removed {
            AttendingSection(event: event, guestList: model.guestList)
            WallPreviewSection(eventId: event.id, entries: model.latestEntries, isVisible: model.wallVisible)
        }
    }

    /// For a guest on the event (invited or answered, not removed).
    private func guestMenu(for event: Event) -> GuestMenu? {
        guard let status = event.myStatus, status != .removed else { return nil }
        return GuestMenu(
            event: event, optedOut: model.optedOut,
            onMute: { muted in Task { await model.setMuted(muted, using: repository) } },
            onLeave: { confirmsLeave = true },
            onOptOut: { host, optOut in Task { await model.setOptedOut(optOut, from: host, using: repository) } }
        )
    }

    private var isConfirmingJoin: Binding<Bool> {
        Binding(get: { joining != nil }, set: { if !$0 { joining = nil } })
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

#Preview("Going, plus-ones allowed, a list to join") {
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

#Preview("Hosting, a list on it") {
    NavigationStack { EventDetailView(eventId: MockEvents.dragFinaleId) }
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
