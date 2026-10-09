import SwiftUI

/// "Save as list", in the invite sheet's foot: "New list" (with its name)
/// or one of your lists, then Cancel and "Save 5". It invites nobody to
/// this event, though a list on events still to come invites them there.
struct SaveAsListForm: View {
    let lists: [PeoplePicker.PickList]
    /// How many are picked.
    let count: Int
    /// The list chosen; nil for a new one.
    @Binding var saveTo: OwnedList.ID?
    @Binding var name: String
    var isSaving = false
    let onCancel: () -> Void
    let onSave: () -> Void

    private var canSave: Bool {
        count > 0 && !isSaving && (saveTo != nil || !name.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            LabeledContent("Save to") {
                Picker("Save to", selection: $saveTo) {
                    Text("New list").tag(OwnedList.ID?.none)
                    ForEach(lists) { list in
                        Text(list.name).tag(OwnedList.ID?.some(list.id))
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }
            if saveTo == nil {
                TextField("Name a new list", text: $name)
                    .accessibilityLabel("New list name")
                    .submitLabel(.done)
                    .onSubmit { if canSave { onSave() } }
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.small)
                    .glassSurface(cornerRadius: Radius.small)
            }
            HStack(spacing: Spacing.small) {
                Button(action: onCancel) { Text("Cancel").frame(maxWidth: .infinity) }
                    .glassButtonStyle()
                Button(action: onSave) {
                    Text("Save \(count)").font(Typography.button).frame(maxWidth: .infinity)
                }
                .accentProminentButtonStyle()
                .disabled(!canSave)
            }
            .controlSize(.large)
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.small)
    }
}

#Preview {
    @Previewable @State var saveTo: OwnedList.ID?
    @Previewable @State var name = ""
    VStack {
        Spacer()
        SaveAsListForm(lists: [.init(id: "a", name: "Drag Race", memberIds: []), .init(id: "b", name: "Climbing", memberIds: [])],
                       count: 5, saveTo: $saveTo, name: $name, onCancel: {}, onSave: {})
            .background(.bar)
    }
    .canopyScreen()
}
