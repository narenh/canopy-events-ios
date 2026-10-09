import SwiftUI

/// A host's "Invite" (the web's invite sheet): the shared picker
/// (`PeoplePickerList`) titled "Invite to <event>", people on the event
/// greyed with their status, and the picked in a tray at the foot beside
/// "Invite 7". A verified host's tray also has "Save as list", which turns
/// it into a small form (`SaveAsListForm`) and invites nobody here.
struct InviteSheet: View {
    let event: Event
    /// Called with how many were invited, after the sheet closes.
    let onInvited: (Int) -> Void

    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var model: PeoplePickerModel
    /// "Save as list"'s form is open.
    @State private var isSavingAsList = false
    /// The list chosen there; nil for a new one, named `newName`.
    @State private var saveTo: OwnedList.ID?
    @State private var newName = ""

    init(event: Event, me: Person.ID?, onInvited: @escaping (Int) -> Void) {
        self.event = event
        self.onInvited = onInvited
        _model = State(initialValue: PeoplePickerModel(target: .event(event), me: me))
    }

    var body: some View {
        NavigationStack {
            PeoplePickerList(model: model)
                .peopleSheetTitle("Invite to \(event.title)")
                .safeAreaInset(edge: .bottom, spacing: 0) { foot }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder private var foot: some View {
        let picked = model.picker.tray
        VStack(spacing: 0) {
            if let notice = model.notice {
                Text(notice)
                    .font(.subheadline)
                    .foregroundStyle(Palette.link)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.large)
                    .padding(.top, Spacing.small)
            }
            if isSavingAsList, !picked.isEmpty {
                SaveAsListForm(lists: model.picker.lists, count: picked.count, saveTo: $saveTo, name: $newName,
                               isSaving: model.isSending, onCancel: { isSavingAsList = false }, onSave: save)
            } else {
                PickerTray(kind: .invite, people: picked, isSending: model.isSending,
                           onUnpick: { model.picker.setPicked([$0.id], false) }, onSend: send,
                           onSaveAsList: session.needsVerification ? nil : { isSavingAsList = true })
            }
        }
        .background(.bar)
        .animation(.snappy, value: isSavingAsList)
    }

    private func send() {
        Task {
            guard let invited = await model.invite(using: repository) else { return }
            dismiss()
            onInvited(invited)
        }
    }

    private func save() {
        Task {
            guard await model.saveAsList(to: saveTo, named: newName, using: repository) else { return }
            isSavingAsList = false
            saveTo = nil
            newName = ""
            if let notice = model.notice { AccessibilityNotification.Announcement(notice).post() }
            session.dataChanged()
        }
    }
}

#Preview("Board game night") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            InviteSheet(event: PreviewData.event(MockEvents.gameNightId), me: MockPeople.maya.id) { _ in }
        }
        .mockEnvironment()
}

#Preview("The finale: Drag Race all invited") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            InviteSheet(event: PreviewData.event(MockEvents.dragFinaleId), me: MockPeople.maya.id) { _ in }
        }
        .mockEnvironment()
}
