import SwiftUI

/// The TMDB backgrounds, as the web's picker: a grid of 3:2 tiles,
/// grouped by title (the title small under each group), with TMDB's logo
/// and credit at the foot (their terms). Picking one previews it on the
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
                    ForEach(list.groups, id: \.first?.id) { group in
                        VStack(alignment: .leading, spacing: Spacing.xSmall) {
                            LazyVGrid(columns: columns, spacing: Spacing.small) {
                                ForEach(group) { tile($0) }
                            }
                            Text(groupTitle(group))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
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

    private func tile(_ background: Background) -> some View {
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
        .accessibilityLabel(background.title)
    }

    private func groupTitle(_ group: [Background]) -> String {
        guard let first = group.first else { return "" }
        return first.year.map { "\(first.title) (\($0))" } ?? first.title
    }
}

#Preview {
    BackgroundPickerSheet(list: BackgroundList(enabled: true, backgrounds: MockBackgrounds.all), chosen: nil) { _ in }
        .preferredColorScheme(.dark)
}
