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

    /// The fade's stops (location, opacity of the base colour), from
    /// docs/api.md: clear to 45%, 70% at the band's top, solid at the foot.
    static let fadeStops: [(Double, Double)] = [
        (0.45, 0), (0.52, 0.06), (0.58, 0.18), (0.63, 0.34), (0.68, 0.52),
        (0.75, 0.70), (0.82, 0.84), (0.90, 0.94), (1, 1),
    ]

    var body: some View {
        let base = ThemeColors(event.theme).base
        CoverPicture(event: event)
            .aspectRatio(3 / 2, contentMode: .fit)
            .overlay {
                LinearGradient(
                    stops: Self.fadeStops.map { .init(color: base.color(opacity: $0.1), location: $0.0) },
                    startPoint: .top, endPoint: .bottom
                )
            }
            .overlay(alignment: .bottomLeading) {
                // Low on the left inside the 2:1: 10 pt above the band.
                GeometryReader { proxy in
                    RelativePill(event: event)
                        .padding(.leading, isInset ? Spacing.xLarge : Spacing.large)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, proxy.size.height / 4 + 10)
                }
            }
            .mask {
                LinearGradient(stops: [.init(color: .black, location: 0.94), .init(color: .clear, location: 1)],
                               startPoint: .top, endPoint: .bottom)
            }
            .clipShape(.rect(topLeadingRadius: isInset ? 20 : 0, topTrailingRadius: isInset ? 20 : 0))
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
