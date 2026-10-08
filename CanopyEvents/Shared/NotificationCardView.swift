import SwiftUI

/// The expanded invite notification, in the app's style: the cover hero
/// (fading itself out; 2:1 in the notification, 3:2 in the app) on the
/// event's colour, the title, the big
/// date and time, the place, the faces going, and two answer buttons.
/// After an answer it shows what was said. Drawn by the notification
/// extension; the app has it too (Profile's Debug section), to look at.
struct NotificationCardView: View {
    let card: NotificationCard
    /// The answer given, once one is (`GOING` / `NOT_GOING`).
    var answered: String?
    /// The width it's drawn at, when the host knows it (the extension
    /// sizes the notification from it); otherwise measured.
    var width: CGFloat?
    let onAnswer: (String) -> Void

    @State private var measuredWidth: CGFloat = 0

    private var drawnWidth: CGFloat { width ?? measuredWidth }

    var body: some View {
        let colors = ThemeColors(card.theme)
        VStack(alignment: .leading, spacing: 0) {
            hero
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { measuredWidth = $0 }
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text(card.title)
                    .font(.system(.title, weight: .heavy))
                    .shadow(color: colors.base.color(opacity: 0.85), radius: 7, y: 2)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Text(dayWords).font(Typography.whenDate)
                    Text(timeWords).font(Typography.whenTime)
                    if let place = card.locationName {
                        Label(place, systemImage: "mappin.and.ellipse")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Palette.muted)
                            .padding(.top, Spacing.xSmall)
                    }
                }
                faces(tint: colors.glow3.color)
                buttons
            }
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.large)
            .padding(.top, -drawnWidth / 6)
            .padding(.bottom, Spacing.large)
        }
        .background(colors.base.color)
        .tint(Palette.accent)
        .environment(\.colorScheme, .dark)
    }

    private var hero: some View {
        heroFrame
            .overlay {
                AsyncImage(url: card.coverUrl) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        CoverArt(eventId: card.eventId, theme: card.theme)
                    }
                }
            }
            .clipped()
            .heroFade()
    }

    /// In the notification (a known width): the clear 2:1 part of the
    /// hero, sized exactly. iOS caps an expanded notification's height
    /// (about 380 pt on a 6.3" phone) and cuts off the top of anything
    /// taller, and the full 3:2 card is about 450 pt. In the app: 3:2.
    @ViewBuilder private var heroFrame: some View {
        if let width {
            Color.clear.frame(width: width, height: width / 2)
        } else {
            Color.clear.aspectRatio(3 / 2, contentMode: .fit)
        }
    }

    @ViewBuilder private func faces(tint: Color) -> some View {
        let shown = Array(card.faces.prefix(5))
        let rest = card.going + card.maybe - shown.count
        if !shown.isEmpty {
            HStack(spacing: Spacing.small) {
                ForEach(shown, id: \.self) { face in
                    AsyncImage(url: face.photoUrl) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Text(face.initials)
                            .font(.system(.subheadline, weight: .bold))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(tint)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(.circle)
                    .overlay { Circle().strokeBorder(.white.opacity(0.28), lineWidth: 1) }
                }
                if rest > 0 {
                    Text("+\(rest)")
                        .font(.system(.subheadline, weight: .heavy))
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.10), in: .circle)
                }
                Spacer(minLength: 0)
                Text("\(card.going) Going · \(card.maybe) Maybe")
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)
            }
        }
    }

    private var buttons: some View {
        CardAnswerButtons(answered: answered, onAnswer: onAnswer)
    }

    private var dayWords: String {
        var style = Date.FormatStyle().weekday(.wide).month(.wide).day()
        style.timeZone = card.zone
        return card.startsAt.formatted(style)
    }

    private var timeWords: String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = card.zone
        return card.startsAt.formatted(style) + (card.endsAt.map { " – " + $0.formatted(style) } ?? "")
    }
}
