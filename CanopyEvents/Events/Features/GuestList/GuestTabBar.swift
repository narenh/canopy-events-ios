import SwiftUI

/// The guests sheet's tabs, one per status there's anyone in, each with
/// its count in the status's fixed color. They wrap onto more lines
/// rather than scroll, so none hide.
struct GuestTabBar: View {
    let tabs: GuestTabs
    /// The tab showing.
    let shown: RSVPStatus?
    let onPick: (RSVPStatus) -> Void

    var body: some View {
        FlowLayout(spacing: Spacing.small) {
            ForEach(tabs.tabs) { status in
                let isOn = status == shown
                Button { onPick(status) } label: {
                    HStack(spacing: Spacing.xSmall) {
                        Text(GuestTabs.title(status))
                        CountPill(count: tabs.count(status), status: status)
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, 6)
                    .background(isOn ? Color.white.opacity(0.16) : Color.clear, in: .capsule)
                    .overlay { Capsule().strokeBorder(.white.opacity(isOn ? 0.7 : 0.2), lineWidth: 1) }
                    .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(GuestTabs.title(status)), \(tabs.count(status))")
                .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let event = PreviewData.event(MockEvents.gameNightId)
    let list = PreviewData.guestList(MockEvents.gameNightId)
    GuestTabBar(tabs: GuestTabs(guests: list.guests, removed: [], counts: list.counts, isHost: true),
                shown: .going) { _ in }
        .padding()
        .canopyScreen(theme: event.theme)
}
