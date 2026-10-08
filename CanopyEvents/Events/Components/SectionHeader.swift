import SwiftUI

/// A small label above a section of a card-based screen, with an
/// optional count: "FRIENDS GOING  3".
struct SectionHeader: View {
    let title: String
    var count: Int?

    var body: some View {
        HStack(spacing: Spacing.small) {
            Text(title.uppercased())
                .font(Typography.sectionLabel)
                .foregroundStyle(Palette.muted)
            if let count {
                Text("\(count)")
                    .font(Typography.sectionLabel)
                    .foregroundStyle(Palette.link)
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    VStack(alignment: .leading) {
        SectionHeader(title: "Hosts")
        SectionHeader(title: "Friends going", count: 3)
    }
    .padding()
    .preferredColorScheme(.dark)
}
