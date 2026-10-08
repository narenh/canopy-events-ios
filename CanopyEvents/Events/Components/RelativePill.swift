import SwiftUI

/// How soon an event is, as a pill on its cover: "NEXT FRIDAY",
/// "HAPPENING NOW" in the accent; "ENDED" plain; "CANCELLED" in danger.
struct RelativePill: View {
    let event: Event

    var body: some View {
        if event.isCancelled {
            pill("Cancelled", foreground: Palette.danger, background: Color.black.opacity(0.35), border: Palette.danger.opacity(0.5))
        } else if let words = RelativeWhen.string(for: event) {
            if EventPhase(event: event) == .over {
                pill(words, foreground: .white, background: Color.white.opacity(0.14), border: Color.white.opacity(0.55))
            } else {
                pill(words, foreground: Palette.onAccent, background: .accentColor, border: .clear)
            }
        }
    }

    private func pill(_ words: String, foreground: Color, background: Color, border: Color) -> some View {
        Text(words.uppercased())
            .font(Typography.tag)
            .tracking(0.5)
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, Spacing.xSmall)
            .background(background, in: .rect(cornerRadius: 8))
            .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(border, lineWidth: 1) }
            .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
    }
}

#Preview {
    VStack(alignment: .leading) {
        RelativePill(event: PreviewData.event(MockEvents.rooftopId))
        RelativePill(event: PreviewData.event(MockEvents.karaokeId))
        RelativePill(event: PreviewData.event(MockEvents.dumplingId))
    }
    .padding()
    .background(Palette.base)
}
