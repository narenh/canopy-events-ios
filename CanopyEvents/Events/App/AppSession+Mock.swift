import Foundation

extension AppSession {
    /// The fully mocked session the app runs on today: a mock auth service
    /// and mock repositories sharing one in-memory backend, signed out.
    /// `extraAccounts` are added to the backend's seed (previews use it).
    static func mock(delay: Duration = .milliseconds(350), extraAccounts: [Me] = []) -> AppSession {
        let backend = MockBackend(delay: delay)
        extraAccounts.forEach(backend.save)
        return AppSession(
            accounts: MockAccountService(backend: backend),
            makeRepository: { MockEventsRepository(backend: backend, personId: $0.value) },
            repository: MockEventsRepository(backend: backend, personId: MockPeople.maya.id)
        )
    }
}
