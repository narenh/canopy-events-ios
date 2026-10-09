import SwiftUI

/// The Profile tab: your photo and name, your lists (each opens in a
/// sheet, shown from here), your contact details (only ever shown to
/// you), whether people can find you, and sign out. Quick accounts also
/// see the verify banner (added by `MainTabView`).
struct ProfileView: View {
    @Environment(AppSession.self) private var session
    /// One of your lists, open in its sheet (`-mockList YES`: Drag Race).
    @State private var openedList: OpenedList? = LaunchOptions.opensList ? OpenedList(id: MockLists.dragRaceId) : nil

    var body: some View {
        Group {
            if let profile = session.profile {
                ProfileForm(model: ProfileModel(profile: profile), openedList: $openedList)
                    .id(profile)  // fresh form state whenever your saved profile changes
            } else {
                ProgressView()
            }
        }
        .sheet(item: $openedList) { ListSheet(listId: $0.id, showsQR: $0.showsQR) }
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
