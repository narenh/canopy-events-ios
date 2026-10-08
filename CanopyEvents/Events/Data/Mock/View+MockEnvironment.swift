import SwiftUI

extension View {
    /// Gives a preview everything a signed-in screen expects: a signed-in
    /// `AppSession` and its instant (no delay) mock repository, as Maya
    /// unless you pass someone else (e.g. `MockPeople.sam`, the unverified
    /// quick account). Previews only.
    func mockEnvironment(signedInAs me: Me = MockPeople.maya) -> some View {
        modifier(MockEnvironment(me: me))
    }
}

/// Signs a fresh mock session in, then shows the content. Used by
/// `mockEnvironment(signedInAs:)`.
private struct MockEnvironment: ViewModifier {
    @State private var session: AppSession
    private let personId: Person.ID

    init(me: Me) {
        _session = State(initialValue: AppSession.mock(delay: .zero, extraAccounts: [me]))
        personId = me.id
    }

    func body(content: Content) -> some View {
        Group {
            if session.isSignedIn {
                content
                    .environment(session)
                    .environment(\.eventsRepository, session.repository)
            } else {
                ProgressView()
            }
        }
        .preferredColorScheme(.dark)
        .task { try? await session.signIn(with: AuthToken(value: personId)) }
    }
}
