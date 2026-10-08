import SwiftUI

/// The Profile tab: your photo and name, your contact details (only ever
/// shown to you), whether people can find you, and sign out. Quick
/// accounts also see the verify banner (added by `MainTabView`).
struct ProfileView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        if let profile = session.profile {
            ProfileForm(model: ProfileModel(profile: profile))
                .id(profile)  // fresh form state whenever your saved profile changes
        } else {
            ProgressView()
        }
    }
}

#Preview("Verified") {
    NavigationStack { ProfileView() }
        .mockEnvironment()
}

#Preview("Unverified, with banner") {
    NavigationStack { ProfileView() }
        .verifyEmailBanner()
        .mockEnvironment(signedInAs: MockPeople.sam)
}
