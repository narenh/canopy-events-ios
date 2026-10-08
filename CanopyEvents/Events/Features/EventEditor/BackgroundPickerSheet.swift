import SwiftUI

/// The TMDB backgrounds: one grid of 3:2 tiles, in the set's order (a
/// title's together), no headings (each tile's label names its title and
/// "n of count"), with TMDB's logo and credit at the foot, the one place
/// the app shows it. Picking one previews it on the
/// editor's hero and jumps the color to it; nothing is saved until Save.
struct BackgroundPickerSheet: View {
    let list: BackgroundList
    let chosen: Background.ID?
    let onPick: (Background) -> Void

    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: Spacing.small)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    LazyVGrid(columns: columns, spacing: Spacing.small) {
                        ForEach(Array(list.groups.enumerated()), id: \.offset) { _, group in
                            ForEach(Array(group.enumerated()), id: \.element.id) { index, background in
                                tile(background, label: "\(background.title), \(index + 1) of \(group.count)")
                            }
                        }
                    }
                    TMDBCredit()
                        .padding(.top, Spacing.medium)
                }
                .padding(Spacing.large)
            }
            .navigationTitle("Backgrounds")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) { dismiss() }
                }
            }
        }
    }

    private func tile(_ background: Background, label: String) -> some View {
        Button {
            onPick(background)
            dismiss()
        } label: {
            Color.clear
                .aspectRatio(3 / 2, contentMode: .fit)
                .overlay {
                    AsyncImage(url: background.thumbUrl) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(.white.opacity(0.08))
                    }
                }
                .clipShape(.rect(cornerRadius: Radius.small))
                .overlay {
                    if background.id == chosen {
                        RoundedRectangle(cornerRadius: Radius.small).strokeBorder(.white, lineWidth: 3)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    BackgroundPickerSheet(list: BackgroundList(enabled: true, backgrounds: MockBackgrounds.all), chosen: nil) { _ in }
        .preferredColorScheme(.dark)
}
