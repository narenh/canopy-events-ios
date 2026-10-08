import SwiftUI

/// The "Guests" card: who sees the guest list, plus-ones per guest, and
/// capacity. No help text: the labels say what each is.
struct EventEditorGuestsSection: View {
    @Bindable var model: EventEditorModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Guests").font(Typography.cardHeading)
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text("Who sees the guest list").font(.subheadline).foregroundStyle(Palette.muted)
                Picker("Who sees the guest list", selection: $model.draft.guestListVisibility) {
                    Text("Everyone with the link").tag(GuestListVisibility.everyone)
                    Text("Only people who've answered").tag(GuestListVisibility.responded)
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
            Stepper(value: $model.draft.guestsAllowed, in: 0...10) {
                LabeledContent("Plus-ones per guest", value: model.draft.guestsAllowed == 0 ? "None" : "\(model.draft.guestsAllowed)")
            }
            Toggle("Capacity", isOn: hasCapacity)
            if let capacity = model.draft.capacity {
                Stepper(value: Binding(get: { capacity }, set: { model.draft.capacity = $0 }), in: 1...10_000) {
                    LabeledContent("Spots", value: "\(capacity)")
                }
            }
        }
        .tint(.accentColor)
        .glassCard()
    }

    /// Turning a limit on starts at 20.
    private var hasCapacity: Binding<Bool> {
        Binding(get: { model.draft.capacity != nil }, set: { model.draft.capacity = $0 ? 20 : nil })
    }
}

#Preview {
    EventEditorGuestsSection(model: EventEditorModel(event: nil))
        .padding()
        .canopyScreen()
}
