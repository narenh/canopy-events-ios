import SwiftUI

/// The picture an event without a cover gets, so every event has the
/// same hero: soft glows on a dark wash, placed by its id and turned to
/// its theme (see `CoverArtLayout`). Fills whatever frame it's given.
struct CoverArt: View {
    let eventId: String
    var theme: EventTheme = .canopyGreen

    var body: some View {
        let art = CoverArtLayout(eventId: eventId, theme: theme)
        let radians = art.angle * .pi / 180
        // CSS angles: 0 is up, clockwise. The wash runs along that line.
        let dx = sin(radians) / 2
        let dy = -cos(radians) / 2
        ZStack {
            LinearGradient(
                colors: [art.wash.color, art.dark.color],
                startPoint: UnitPoint(x: 0.5 - dx, y: 0.5 - dy), endPoint: UnitPoint(x: 0.5 + dx, y: 0.5 + dy)
            )
            EllipticalGradient(
                colors: [art.glow1.color, art.glow1.color(opacity: 0)],
                center: UnitPoint(x: art.glow1X, y: art.glow1Y), endRadiusFraction: 0.75
            )
            EllipticalGradient(
                colors: [art.glow2.color, art.glow2.color(opacity: 0)],
                center: UnitPoint(x: art.glow2X, y: art.glow2Y), endRadiusFraction: 0.7
            )
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack {
        ForEach([MockEvents.gameNightId, MockEvents.karaokeId, MockEvents.triviaId], id: \.self) { id in
            CoverArt(eventId: id).aspectRatio(3 / 2, contentMode: .fit)
        }
        CoverArt(eventId: MockEvents.gameNightId, theme: .hue(300)).aspectRatio(3 / 2, contentMode: .fit)
    }
}
