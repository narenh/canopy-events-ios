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
    @State private var notifications: NotificationResponder
    private let personId: Person.ID

    init(me: Me) {
        let session = AppSession.mock(delay: .zero, extraAccounts: [me])
        _session = State(initialValue: session)
        _notifications = State(initialValue: NotificationResponder(session: session))
        personId = me.id
    }

    func body(content: Content) -> some View {
        Group {
            if session.isSignedIn {
                content
                    .environment(session)
                    .environment(notifications)
                    .environment(\.eventsRepository, session.repository)
            } else {
                ProgressView()
            }
        }
        .preferredColorScheme(.dark)
        .task { try? await session.signIn(with: AuthToken(value: personId)) }
    }
}
