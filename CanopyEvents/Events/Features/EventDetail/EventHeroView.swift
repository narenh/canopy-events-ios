import SwiftUI

/// The top of the event page, the web's hero: the cover (or the generated
/// art) in a 3:2 frame. Its top 2:1 shows the picture clearly, with the
/// how-soon pill low on the left; the band below (the last sixth of the
/// width) has faded into the theme's base colour, and the title starts on
/// it (`EventHeadView`). The fade eases in with the web's stops, and the
/// last 6% melts into the mesh.
struct EventHeroView: View {
    let event: Event
    /// Rounded top corners: in the iPad column, not edge to edge.
    var isInset = false

    var body: some View {
        CoverPicture(event: event)
            .aspectRatio(3 / 2, contentMode: .fit)
            .heroFade(event.theme)
            .overlay(alignment: .bottomLeading) {
                // Low on the left inside the 2:1: 10 pt above the band.
                GeometryReader { proxy in
                    RelativePill(event: event)
                        .padding(.leading, isInset ? Spacing.xLarge : Spacing.large)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, proxy.size.height / 4 + 10)
                }
            }
            .clipShape(.rect(topLeadingRadius: isInset ? 18 : 0, topTrailingRadius: isInset ? 18 : 0))
            .accessibilityHidden(true)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.large) {
            EventHeroView(event: PreviewData.event(MockEvents.rooftopId))
            EventHeroView(event: PreviewData.event(MockEvents.gameNightId))
            EventHeroView(event: PreviewData.event(MockEvents.karaokeId), isInset: true)
        }
    }
    .canopyScreen()
}
