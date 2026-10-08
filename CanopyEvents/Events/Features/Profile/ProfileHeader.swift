import SwiftUI

/// Your photo and name at the top of Profile. Changing the photo is a
/// placeholder: photos are managed by the account service.
struct ProfileHeader: View {
    let me: Me

    var body: some View {
        VStack(spacing: Spacing.small) {
            Avatar(person: me.person, size: 96)
            Text(me.person.fullName)
                .font(.title2.weight(.semibold))
            if let email = me.email {
                Label(email, systemImage: me.emailVerified ? "checkmark.seal.fill" : "exclamationmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(me.emailVerified ? Palette.link : Color.orange)
            }
            Button("Change photo") {}
                .font(.subheadline)
                .disabled(true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: Spacing.xxLarge) {
        ProfileHeader(me: MockPeople.maya)
        ProfileHeader(me: MockPeople.sam)
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
