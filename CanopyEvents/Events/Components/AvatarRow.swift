import SwiftUI

/// One row of big round faces, never overlapping, as many as fit the
/// width at least 5 pt apart, spread evenly; the last a "+N" circle when
/// there are more people than fit. The web's Attending row.
struct AvatarRow: View {
    let people: [Person]
    /// Everyone the row stands for (people going or maybe), which can be
    /// more than `people`: "+N" counts the rest.
    let total: Int
    /// The initials' circle colour (the event's brightest glow).
    var tint: Color = Palette.glowBright

    @ScaledMetric(relativeTo: .title) private var size: CGFloat = 56
    @State private var width: CGFloat = 0
    private let minimumGap: CGFloat = 5

    var body: some View {
        Color.clear
            .frame(height: size)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
            .overlay(alignment: .leading) {
                HStack(spacing: gap) {
                    ForEach(shown) { person in
                        Avatar(person: person, size: size, tint: tint)
                    }
                    if rest > 0 {
                        Text("+\(rest)")
                            .font(.system(.title3, weight: .heavy))
                            .minimumScaleFactor(0.6)
                            .frame(width: size, height: size)
                            .background(.white.opacity(0.10), in: .circle)
                            .overlay { Circle().strokeBorder(.white.opacity(0.55), lineWidth: 1) }
                            .accessibilityLabel("\(rest) more")
                    }
                }
            }
    }

    private var slots: Int {
        max(2, Int((width + minimumGap) / (size + minimumGap)))
    }

    private var shown: [Person] {
        let all = max(people.count, total)
        return Array(people.prefix(all <= slots ? slots : slots - 1))
    }

    private var rest: Int { max(people.count, total) - shown.count }

    /// Even spacing across the whole width (CSS `space-between`).
    private var gap: CGFloat {
        slots > 1 ? max(minimumGap, (width - CGFloat(slots) * size) / CGFloat(slots - 1)) : 0
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.large) {
        AvatarRow(people: MockPeople.everyone, total: 146)
        AvatarRow(people: Array(MockPeople.everyone.prefix(3)), total: 3)
    }
    .padding()
    .canopyScreen()
}
