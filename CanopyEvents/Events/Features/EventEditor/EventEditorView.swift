import SwiftUI

/// The create/edit form, shown as a sheet, drawn as the event will look:
/// the cover hero (with its photo buttons), the title typed where the
/// title goes, the date and times as big as the page's, the zone under
/// them, the place, address and description in the same unbordered top;
/// then the Guests and Colour cards, and Save in a bar at the bottom.
/// The background is the event's colour as it's being picked. No help
/// text. Cancelling, deleting and the rest live in the event page's ⋯.
struct EventEditorView: View {
    /// Called with the saved event, after the sheet closes.
    let onSaved: (Event) -> Void

    @Environment(\.eventsRepository) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var model: EventEditorModel
    @State private var isWide = false
    @State private var heroWidth: CGFloat = 0
    @State private var overscroll: CGFloat = 0
    @FocusState private var titleFocused: Bool

    /// Pass nil to make a new event.
    init(event: Event?, onSaved: @escaping (Event) -> Void) {
        self.onSaved = onSaved
        _model = State(initialValue: EventEditorModel(event: event))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    EditorHeroView(model: model, isInset: isWide, overscroll: overscroll)
                        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { heroWidth = $0 }
                    VStack(alignment: .leading, spacing: Spacing.xLarge) {
                        titleField
                        EditorWhenView(model: model)
                        details
                    }
                    .padding(.horizontal, isWide ? Spacing.xLarge : Spacing.large)
                    .padding(.top, -heroWidth / 6)
                    VStack(spacing: Spacing.large) {
                        EventEditorGuestsSection(model: model)
                        EditorColourSection(model: model)
                    }
                    .padding(.horizontal, isWide ? 0 : Spacing.large)
                    .padding(.top, Spacing.xxLarge)
                }
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.xLarge)
            }
            .dismissesKeyboardOnScroll()
            .trackingOverscroll($overscroll)
            .onGeometryChange(for: Bool.self) { $0.size.width >= 700 } action: { isWide = $0 }
            .safeAreaInset(edge: .bottom) { saveBar }
            .accessibilityLabel(model.isNew ? "New Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) { dismiss() }
                }
            }
            .disabled(model.isSaving)
            .errorAlert($model.errorMessage)
            .eventAccent(model.draft.theme)
            .canopyScreen(theme: model.draft.theme)
        }
    }

    /// The title, as big as the page's, wrapping as it will there. Return
    /// doesn't add a line (a pasted line break becomes a space).
    private var titleField: some View {
        TextField("Title", text: $model.draft.title,
                  prompt: Text("Event title").foregroundStyle(.white.opacity(0.55)), axis: .vertical)
            .font(Typography.eventTitle)
            .foregroundStyle(.white)
            .focused($titleFocused)
            .submitLabel(.done)
            .onChange(of: model.draft.title) { _, title in
                guard title.contains(where: \.isNewline) else { return }
                model.draft.title = title.split(whereSeparator: \.isNewline).joined(separator: " ")
                titleFocused = false
            }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            EditorField(label: "Place", text: $model.draft.locationName, prompt: "Add a place", font: .body.weight(.semibold))
            EditorField(label: "Address", text: $model.draft.locationAddress,
                        prompt: "Address (only signed-in guests see it)")
            EditorField(label: "Description", text: $model.draft.description,
                        prompt: "What's happening, what to bring, anything people should know", axis: .vertical)
                .lineLimit(3...12)
        }
    }

    private var saveBar: some View {
        Button {
            Task { await save() }
        } label: {
            Text(model.isNew ? "Create event" : "Save")
                .font(Typography.button)
                .frame(maxWidth: .infinity)
        }
        .glassProminentButtonStyle()
        .controlSize(.large)
        .disabled(!model.draft.isValid || model.isSaving)
        .frame(maxWidth: 680)
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.small)
    }

    private func save() async {
        guard let event = await model.save(using: repository) else { return }
        dismiss()
        onSaved(event)
    }
}

#Preview("New") {
    EventEditorView(event: nil) { _ in }
        .mockEnvironment()
}

#Preview("Edit, with a cover") {
    EventEditorView(event: PreviewData.event(MockEvents.rooftopId)) { _ in }
        .mockEnvironment()
}

#Preview("Edit, long title, grey") {
    EventEditorView(event: PreviewData.event(MockEvents.galleryId)) { _ in }
        .mockEnvironment()
}
