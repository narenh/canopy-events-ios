import SwiftUI

/// The details under the description in the editor: the rows added so
/// far, then a row of chips ("+ Link", "+ Info", ... "+ Stay", "+ Phone")
/// to add one (up to 10), as the web's editor has them.
struct EditorDetailsSection: View {
    @Bindable var model: EventEditorModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            ForEach($model.draft.details) { $detail in
                EditorDetailRow(detail: $detail) {
                    model.draft.details.removeAll { $0.id == detail.id }
                }
            }
            if model.draft.details.count < 10 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.small) {
                        ForEach(EventDetailType.addable, id: \.self) { type in
                            Button("+ \(type.chipTitle)") {
                                model.draft.details.append(EventDetailInput(type: type, value: ""))
                            }
                            .font(.subheadline.weight(.semibold))
                            .buttonBorderShape(.capsule)
                            .glassButtonStyle()
                        }
                    }
                }
                .accessibilityLabel("Add details")
            }
        }
    }
}
