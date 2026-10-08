import SwiftUI

/// A quiet field with a dashed edge, for the editor's top card: it reads
/// like the event page and still looks editable. No autofill on any
/// editor field (the web's rule: these are the event's, not yours), and
/// no autocorrection on a one-line one.
struct EditorField: View {
    let label: String
    @Binding var text: String
    var prompt: String
    var axis: Axis = .horizontal
    var font: Font = .body

    var body: some View {
        TextField(label, text: $text, prompt: Text(prompt).foregroundStyle(Palette.muted.opacity(0.8)), axis: axis)
            .font(font)
            .textContentType(nil)
            .autocorrectionDisabled(axis == .horizontal)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(.black.opacity(0.18), in: .rect(cornerRadius: Radius.small))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.small)
                    .strokeBorder(.white.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            }
    }
}
