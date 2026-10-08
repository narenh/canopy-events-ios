import SwiftUI

/// One detail being edited, under the description, as the web's editor
/// has it: the type's icon, its fields (a link: its address, then the
/// text to show; a phone: the number; the rest: an optional heading, then
/// the text), and a × to take it off. No autofill: these aren't yours.
struct EditorDetailRow: View {
    @Binding var detail: EventDetailInput
    let onRemove: () -> Void

    @Environment(\.eventAccent) private var accent

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.medium) {
            Image(systemName: detail.type.systemImage)
                .foregroundStyle(accent.accent)
                .frame(width: 22)
                .padding(.top, Spacing.small)
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                switch detail.type {
                case .link:
                    EditorField(label: "Link address", text: $detail.value, prompt: detail.type.placeholder)
                        .keyboardKind(.url)
                    EditorField(label: "Link text", text: label, prompt: "Link text")
                case .phone:
                    EditorField(label: "Phone number", text: $detail.value, prompt: detail.type.placeholder)
                        .keyboardKind(.phone)
                default:
                    EditorField(label: "Heading for \(detail.type.heading ?? "")", text: label,
                                prompt: detail.type.heading ?? "", font: .body.weight(.semibold))
                    EditorField(label: detail.type.heading ?? "", text: $detail.value, prompt: detail.type.placeholder,
                                axis: .vertical)
                        .lineLimit(2...8)
                }
            }
            Button("Remove \((detail.type.heading ?? detail.type.chipTitle).lowercased())", systemImage: "xmark.circle.fill",
                   action: onRemove)
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(Palette.muted)
                .buttonStyle(.borderless)
                .padding(.top, Spacing.small)
        }
    }

    /// The optional label as a plain string ("" for none).
    private var label: Binding<String> {
        Binding(get: { detail.label ?? "" }, set: { detail.label = $0.isEmpty ? nil : $0 })
    }
}
