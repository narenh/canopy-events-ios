import SwiftUI

/// The "Color" card: the slider, and "Match photo" when the cover's
/// color is known. The page behind the editor previews it.
struct EditorColorSection: View {
    @Bindable var model: EventEditorModel

    @Environment(\.eventAccent) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text("Color").font(Typography.cardHeading)
                Spacer()
                Text(ThemeSlider.words(for: model.draft.theme))
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
            ThemeSlider(theme: $model.draft.theme)
            if let match = model.coverMatch {
                Button("Match photo", systemImage: "photo") { model.matchPhoto() }
                    .foregroundStyle(accent.text)
                    .glassButtonStyle()
                    .disabled(match == model.draft.theme)
            }
        }
        .glassCard()
    }
}
