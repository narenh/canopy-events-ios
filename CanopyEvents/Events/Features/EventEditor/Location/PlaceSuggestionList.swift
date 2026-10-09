import SwiftUI

/// The Location field's suggestions, on glass under the field: first,
/// always, Use "<typed>" (a pencil: the text as it is, no map), then Apple
/// Maps', each its title and, muted, its subtitle, with `mappin` for a
/// named place and `house` for an address. `onPick` gets nil for Use "…".
struct PlaceSuggestionList: View {
    let query: String
    let suggestions: [PlaceSuggestion]
    let onPick: (PlaceSuggestion?) -> Void

    var body: some View {
        VStack(spacing: 0) {
            row(symbol: "pencil", title: "Use “\(query)”", subtitle: "") { onPick(nil) }
            ForEach(suggestions) { suggestion in
                Divider().overlay(.white.opacity(0.12))
                row(symbol: suggestion.kind.symbol, title: suggestion.title, subtitle: suggestion.subtitle) {
                    onPick(suggestion)
                }
            }
        }
        .glassSurface(cornerRadius: Radius.small)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Places")
    }

    private func row(symbol: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.medium) {
                Image(systemName: symbol)
                    .foregroundStyle(Palette.muted)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Text(title)
                        .foregroundStyle(.white)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Palette.muted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlaceSuggestionList(query: "dolores", suggestions: PreviewPlaceSearch.samples) { _ in }
        .padding()
        .canopyScreen()
}
