import SwiftUI

/// A label above a group in a list, with an optional count: "Going  3"
/// (the web's group heading: 15 pt bold, no capitals).
struct SectionHeader: View {
    let title: String
    var count: Int?

    var body: some View {
        HStack(spacing: Spacing.small) {
            Text(title)
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
