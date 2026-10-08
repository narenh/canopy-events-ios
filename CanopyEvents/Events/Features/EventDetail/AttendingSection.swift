import SwiftUI

/// Who's coming: "Attending", the counts ("4 Going · 2 Maybe"), a "View
/// all" capsule to the whole list, and one row of big faces (friends
/// first) ending in "+N". While the host shows names only to people who
/// have answered, the counts stay and a line says why there are no faces.
struct AttendingSection: View {
    let event: Event
    /// The first page of the guest list, or nil while it loads.
    let guestList: GuestList?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    Text("Attending")
                        .font(Typography.sectionTitle)
                        .accessibilityAddTraits(.isHeader)
                    Text(Attending.summary(event.counts))
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                }
                Spacer(minLength: Spacing.small)
                if let guestList, guestList.guestsVisible, !guestList.guests.isEmpty {
                    NavigationLink(value: Route.guestList(event.id)) {
                        Text("View all")
                            .font(.subheadline.weight(.bold))
                            .padding(.horizontal, Spacing.small)
                    }
                    .buttonBorderShape(.capsule)
                    .glassButtonStyle()
                }
            }
            if let guestList {
                if guestList.guestsVisible {
                    row(guestList)
                } else {
                    hidden
                }
            }
        }
        .glassCard()
    }

    @ViewBuilder private func row(_ guestList: GuestList) -> some View {
        let people = Attending.people(friends: event.friendsGoing?.people ?? [], guests: guestList.guests)
        if people.isEmpty {
            Text("No answers yet.")
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
        } else {
            AvatarRow(people: people, total: event.counts.going + event.counts.maybe,
                      tint: ThemeColors(event.theme).glow3.color)
        }
    }

    private var hidden: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            if let friends = event.friendsGoing?.count, friends > 0 {
                Text(friends == 1 ? "1 friend going" : "\(friends) friends going")
                    .font(.subheadline.weight(.semibold))
            }
            Text("The host shows who's coming to people who've answered. Answer to see the list.")
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            VStack {
                AttendingSection(event: PreviewData.event(MockEvents.birthdayId),
                                 guestList: PreviewData.guestList(MockEvents.birthdayId))
                AttendingSection(event: PreviewData.event(MockEvents.hikeId),
                                 guestList: PreviewData.guestList(MockEvents.hikeId))
            }
            .padding()
        }
        .canopyScreen()
    }
}
