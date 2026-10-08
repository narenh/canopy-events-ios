import SwiftUI

/// The create/edit form, shown as a sheet: title, description, when (in
/// the event's time zone), where, cover, capacity, plus-ones and who sees
/// the guest list. Editing also offers "Cancel event".
struct EventEditorView: View {
    /// Called with the saved (or cancelled) event, after the sheet closes.
    let onSaved: (Event) -> Void

    @Environment(\.eventsRepository) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var model: EventEditorModel
    @State private var confirmsCancel = false

    /// Pass nil to make a new event.
    init(event: Event?, onSaved: @escaping (Event) -> Void) {
        self.onSaved = onSaved
        _model = State(initialValue: EventEditorModel(event: event))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $model.draft.title)
                        .font(.headline)
                    TextField("Description", text: $model.draft.description, axis: .vertical)
                        .lineLimit(3...8)
                }
                EventEditorWhenSection(model: model)
                Section("Where") {
                    TextField("Place name", text: $model.draft.locationName)
                    TextField("Address", text: $model.draft.locationAddress)
                }
                Section("Cover") {
                    CoverImagePickerPlaceholder(currentUrl: model.original?.coverImageUrl)
                }
                EventEditorGuestsSection(model: model)
                if !model.isNew && model.original?.isCancelled == false {
                    Section {
                        Button("Cancel event", role: .destructive) { confirmsCancel = true }
                    }
                }
            }
            .navigationTitle(model.isNew ? "New event" : "Edit event")
            .inlineNavigationTitle()
            .toolbar { toolbar }
            .disabled(model.isSaving)
            .confirmationDialog("Cancel this event?", isPresented: $confirmsCancel, titleVisibility: .visible) {
                Button("Cancel event", role: .destructive) { Task { await cancelEvent() } }
            } message: {
                Text("Guests are told, and the link keeps working with a cancelled notice.")
            }
            .errorAlert($model.errorMessage)
        }
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close", role: .cancel) { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(model.isNew ? "Create" : "Save", role: .confirm) { Task { await save() } }
                .disabled(!model.draft.isValid)
        }
    }

    private func save() async {
        guard let event = await model.save(using: repository) else { return }
        dismiss()
        onSaved(event)
    }

    private func cancelEvent() async {
        guard let event = await model.cancelEvent(using: repository) else { return }
        dismiss()
        onSaved(event)
    }
}

#Preview("New") {
    EventEditorView(event: nil) { _ in }
        .mockEnvironment()
}

#Preview("Edit") {
    EventEditorView(event: PreviewData.event(MockEvents.gameNightId)) { _ in }
        .mockEnvironment()
}
