import SwiftUI

/// Switches between the signed-out sign-in flow and the main tabs, and
/// gives the signed-in screens their repository.
struct RootView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if session.isSignedIn {
                MainTabView()
                    .environment(\.eventsRepository, session.repository)
            } else {
                SignInView()
            }
        }
        .preferredColorScheme(.dark)
        .task { await signInFromLaunchOptions() }
        // Back from the background: things may have changed meanwhile
        // (an invite answered from a notification).
        .onChange(of: scenePhase) { _, phase in
            if phase == .active && session.isSignedIn { session.dataChanged() }
        }
    }

    /// Debug builds can skip the sign-in screen (see `LaunchOptions`).
    private func signInFromLaunchOptions() async {
        switch LaunchOptions.mockAccount {
        case "maya": try? await session.signIn(with: AuthToken(value: MockPeople.maya.id))
        case "quick": try? await session.signIn(with: AuthToken(value: MockPeople.sam.id))
        case "new": try? await session.quickSignUp(firstName: "Ada", lastName: "Ng", email: "ada@example.com")
        default: break
        }
    }
}

#Preview("Signed out") {
    let session = AppSession.mock()
    RootView()
        .environment(session)
        .environment(NotificationResponder(session: session))
}

#Preview("Signed in") {
    RootView()
        .mockEnvironment()
}
