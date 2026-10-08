import SwiftUI

/// "3 friends going", with their faces once you can see the guest list.
struct FriendsGoingSection: View {
    let friendsGoing: FriendsGoing

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            SectionHeader(title: "Friends going", count: friendsGoing.count)
            if friendsGoing.people.isEmpty {
                Text("RSVP to see which friends are going.")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            } else {
                AvatarStack(people: friendsGoing.people)
                Text(friendsGoing.people.map(\.shortName).formatted(.list(type: .and)))
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
        }
        .glassCard()
    }
}

#Preview {
    VStack {
        FriendsGoingSection(friendsGoing: PreviewData.event(MockEvents.rooftopId).friendsGoing!)
        FriendsGoingSection(friendsGoing: FriendsGoing(count: 2, people: []))
    }
    .padding()
    .canopyScreen()
    .preferredColorScheme(.dark)
}
