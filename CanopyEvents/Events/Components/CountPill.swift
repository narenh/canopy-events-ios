import SwiftUI

/// A count in a status's fixed color (the same as `StatusBadge`'s, never
/// the event's): the guests sheet's tabs. Can't Go and Removed are plain.
struct CountPill: View {
    let count: Int
    let status: RSVPStatus

    var body: some View {
        let number = Text("\(count)")
            .font(Typography.tag)
            .monospacedDigit()
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
        if let colors = StatusBadge.colors(for: .status(status)) {
            number
                .foregroundStyle(colors.text.color)
                .background(colors.pill.color, in: .capsule)
        } else {
            number
                .foregroundStyle(.white)
                .background(.white.opacity(0.10), in: .capsule)
                .overlay { Capsule().strokeBorder(.white.opacity(0.55), lineWidth: 1) }
        }
    }
}

#Preview {
    HStack {
        ForEach(GuestTabs.order, id: \.self) { CountPill(count: 12, status: $0) }
    }
    .padding()
    .canopyScreen()
}
