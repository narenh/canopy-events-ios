import SwiftUI

/// The editor's Location field ("Place or address"), as the web's: one
/// quiet box; under a pick, its address muted with a × to clear it; and
/// while typing, the suggestions under the box (Use "<typed>" first, then
/// Apple Maps'). A row picks it and lets the field go.
struct EditorLocationField: View {
    let model: LocationFieldModel

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            EditorField(label: "Location", text: Binding(get: { model.text }, set: model.edit),
                        prompt: "Place or address", font: .body.weight(.semibold))
                .focused($focused)
                .submitLabel(.done)
                .onSubmit { model.close() }
            if !model.line.isEmpty {
                picked
            }
            if focused && model.offersSuggestions {
                PlaceSuggestionList(query: model.query, suggestions: model.suggestions) { suggestion in
                    focused = false
                    if let suggestion {
                        Task { await model.pick(suggestion) }
                    }
                }
            }
        }
        .onChange(of: focused) { _, isFocused in
            if !isFocused { model.close() }
        }
    }

    /// A pick's address, and the × that clears the field.
    private var picked: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.small) {
            Text(model.line)
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Clear location", systemImage: "xmark.circle.fill") {
                model.clear()
                focused = true
            }
            .labelStyle(.iconOnly)
            .foregroundStyle(Palette.muted)
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, Spacing.medium)
    }
}

#Preview("Picked, and empty") {
    VStack(spacing: Spacing.xLarge) {
        EditorLocationField(model: LocationFieldModel(
            location: PreviewData.event(MockEvents.birthdayId).location, search: PreviewPlaceSearch()))
        EditorLocationField(model: LocationFieldModel(location: EventLocation(), search: PreviewPlaceSearch()))
    }
    .padding()
    .canopyScreen()
}
