import SwiftUI

/// The top of the event page, the web's hero: the cover (or the generated
/// art) in a 3:2 frame. Its top 2:1 shows the picture clearly, with the
/// how-soon pill low on the left; the band below (the last sixth of the
/// width) is where the picture has faded itself out into the page (a mask,
/// nothing drawn over it), and the title starts on it (`EventHeadView`).
/// Pulled down, the picture stays put and the pill, title and the rest
/// slide down over it.
struct EventHeroView: View {
    let event: Event
    /// Rounded top corners: in the iPad column, not edge to edge.
    var isInset = false
    /// How far the page is pulled down past its top: the picture stays
    /// there while the rest moves (`pinnedWhilePulled`).
    var overscroll: CGFloat = 0

    var body: some View {
        CoverPicture(event: event)
            .aspectRatio(3 / 2, contentMode: .fit)
            .heroFade()
            .clipShape(.rect(topLeadingRadius: isInset ? 18 : 0, topTrailingRadius: isInset ? 18 : 0))
            .pinnedWhilePulled(overscroll)
            .overlay(alignment: .bottomLeading) {
                // Low on the left inside the 2:1: 10 pt above the band.
                GeometryReader { proxy in
                    RelativePill(event: event)
                        .padding(.leading, isInset ? Spacing.xLarge : Spacing.large)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, proxy.size.height / 4 + 10)
                }
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.large) {
            EventHeroView(event: PreviewData.event(MockEvents.rooftopId))
            EventHeroView(event: PreviewData.event(MockEvents.gameNightId))
            EventHeroView(event: PreviewData.event(MockEvents.karaokeId), isInset: true)
            // As if pulled down 120 pt: the pill has come down 120 pt over
            // the picture, which hasn't moved.
            EventHeroView(event: PreviewData.event(MockEvents.rooftopId), overscroll: 120)
                .padding(.top, 120)
        }
    }
    .canopyScreen()
}
