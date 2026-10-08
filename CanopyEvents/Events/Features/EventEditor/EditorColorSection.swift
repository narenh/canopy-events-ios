import SwiftUI

/// The "Color" card: the Color slider (grey, then the wheel), with a
/// small picture button at the right of its label line to match the
/// cover's color when it's known; and, while Color is grey, an Accent
/// slider (white, then the wheel) for the buttons, pill, icons and links.
/// The page behind the editor previews both.
struct EditorColorSection: View {
    @Bindable var model: EventEditorModel

    @Environment(\.eventAccent) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text("Color").font(Typography.cardHeading)
                Text(Self.words(for: model.draft.theme))
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                Spacer()
                if let match = model.coverMatch {
                    Button("Match photo", systemImage: "photo") { model.matchPhoto() }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(accent.text)
                        .buttonStyle(.borderless)
                        .disabled(match == model.draft.theme)
                }
            }
            WheelSlider(
                value: Binding(get: { ThemeSliderScale.value(for: model.draft.theme) },
                               set: { model.draft.theme = ThemeSliderScale.theme(at: $0) }),
                start: WheelSlider.grey, thumbColor: ThemeColors(model.draft.theme).glow3.color,
                label: "Color", valueWords: Self.words(for: model.draft.theme)
            )
            if model.draft.themeGrayscale {
                HStack {
                    Text("Accent").font(Typography.cardHeading)
                    Text(Self.accentWords(model.draft.accentHue))
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                }
                .padding(.top, Spacing.small)
                WheelSlider(
                    value: Binding(get: { AccentSliderScale.value(for: model.draft.accentHue) },
                                   set: { model.draft.accentHue = AccentSliderScale.accentHue(at: $0) }),
                    start: RGB(hex: "#ffffff"), thumbColor: model.draft.accent.accent.color,
                    label: "Accent", valueWords: Self.accentWords(model.draft.accentHue)
                )
            }
        }
        .glassCard()
    }

    /// "No color", "Canopy green", or "300°", as the web says it.
    static func words(for theme: EventTheme) -> String {
        switch theme {
        case .grayscale: "No color"
        case .canopyGreen: "Canopy green"
        case .hue(let hue): "\(hue)°"
        }
    }

    /// "White" or "30°".
    static func accentWords(_ hue: Int?) -> String {
        hue.map { "\($0)°" } ?? "White"
    }
}
