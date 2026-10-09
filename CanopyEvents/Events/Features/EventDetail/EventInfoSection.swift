import SwiftUI

/// The rest of the event's top section, under the title and when: where
/// (with a pin, the address opens directions; without, "Open in Maps"), who's hosting, spots left, the host's extra details,
/// and the description.
/// No card and no border: the cover runs edge to edge above it, so the
/// whole top reads as one piece on the event's background.
struct EventInfoSection: View {
    let event: Event

    @Environment(\.eventAccent) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            if event.locationName != nil || event.locationAddress != nil || event.locationAddressHidden {
                place
            }
            if !event.hosts.isEmpty {
                hostedBy
            }
            if let spots {
                Text(spots)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(event.isFull ? .white : accent.text)
            }
            ForEach(Array(event.shownDetails.enumerated()), id: \.offset) { _, detail in
                EventDetailRow(detail: detail)
            }
            if event.hiddenDetails > 0 {
                Text("More details show once you sign in.")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
            if let description = event.description, !description.isEmpty {
                Divider().overlay(.white.opacity(0.22))
                Text(description)
                    .foregroundStyle(.white)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var place: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.medium) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundStyle(accent.accent)
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                if let name = event.locationName {
                    Text(name).fontWeight(.semibold)
                }
                if let address = event.locationAddress, event.location.hasPin {
                    // A pin: the address is the way there.
                    Button(address) { EventDirections.open(event) }
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.leading)
                        .accentLink(accent)
                        .buttonStyle(.plain)
                        .accessibilityHint("Directions in Maps")
                } else if let address = event.locationAddress {
                    Text(address)
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                    if let maps = URL(string: "https://maps.apple.com/?q=" + (address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) {
                        Link("Open in Maps", destination: maps)
                            .font(.subheadline.weight(.semibold))
                            .accentLink(accent)
                    }
                } else if event.locationAddressHidden {
                    Text("Sign in to see the address")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                }
            }
        }
    }

    private var hostedBy: some View {
        let people = event.hosts.map(\.person)
        return HStack(spacing: Spacing.medium) {
            AvatarStack(people: Array(people.prefix(3)), size: 32, maxShown: 3)
            Text("Hosted by \(people.map(\.fullName).formatted(.list(type: .and)))")
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }

    /// "3 spots left" or "Full", while the event is still on.
    private var spots: String? {
        guard event.capacity != nil, let left = event.spotsLeft, EventPhase(event: event).isOpen else { return nil }
        if left == 0 { return "Full. New answers join the waitlist." }
        return left == 1 ? "1 spot left" : "\(left) spots left"
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xxLarge) {
            EventInfoSection(event: PreviewData.event(MockEvents.rooftopId))
            EventInfoSection(event: PreviewData.event(MockEvents.birthdayId))
            EventInfoSection(event: PreviewData.event(MockEvents.supperClubId))
        }
        .padding()
    }
    .canopyScreen()
}
