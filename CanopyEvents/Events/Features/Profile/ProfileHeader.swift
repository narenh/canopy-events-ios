import SwiftUI

/// Your photo and name at the top of Profile. Changing the photo is a
/// placeholder: photos are managed by the account service.
struct ProfileHeader: View {
    let profile: AccountProfile

    var body: some View {
        VStack(spacing: Spacing.small) {
            Avatar(person: profile.person, size: 96)
            Text(profile.person.fullName)
                .font(.title2.weight(.semibold))
            Label(profile.email, systemImage: profile.emailVerified ? "checkmark.seal.fill" : "exclamationmark.circle")
                .font(.subheadline)
                .foregroundStyle(profile.emailVerified ? Palette.link : Color.orange)
            Button("Change photo") {}
                .font(.subheadline)
                .disabled(true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: Spacing.xxLarge) {
        ProfileHeader(profile: MockPeople.maya)
        ProfileHeader(profile: MockPeople.sam)
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
