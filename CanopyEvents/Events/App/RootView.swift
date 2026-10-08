import SwiftUI

/// Switches between the signed-out sign-in flow and the main tabs, and
/// gives the signed-in screens their repository.
struct RootView: View {
    @Environment(AppSession.self) private var session

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
    RootView()
        .environment(AppSession.mock())
}

#Preview("Signed in") {
    RootView()
        .mockEnvironment()
}
