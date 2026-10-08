import Foundation

/// The events API as one signed-in person sees it, answered from the
/// shared in-memory `MockBackend`. It applies the server's rules through
/// `MockRules`, so visibility, counts and the waitlist behave for real.
///
/// The CRUD for hosting, guests and the wall is in the `+Hosting`,
/// `+Guests` and `+Wall` extensions next to this file.
final class MockEventsRepository: EventsRepository {
    let backend: MockBackend
    let personId: Person.ID

    init(backend: MockBackend, personId: Person.ID) {
        self.backend = backend
        self.personId = personId
    }

    /// A repository with its own fresh backend, for previews and defaults.
    convenience init(signedInAs me: Me = MockPeople.maya, delay: Duration = .milliseconds(350)) {
        let backend = MockBackend(delay: delay)
        backend.save(me)
        self.init(backend: backend, personId: me.id)
    }

    /// You, as the backend has you now (verifying your email changes it).
    var currentUser: Me {
        backend.account(id: personId) ?? MockPeople.maya
    }

    var records: [MockEventRecord] {
        get { backend.records }
        set { backend.records = newValue }
    }

    var posts: [WallPost] {
        get { backend.posts }
        set { backend.posts = newValue }
    }

    func pause() async {
        await backend.pause()
    }

    // MARK: You

    func me() async throws -> MeEnvelope {
        await pause()
        let verifyUrl = URL(string: "https://account.canopysf.com/profile?verify=1")
        return MeEnvelope(
            person: currentUser,
            verifyUrl: currentUser.emailVerified ? nil : verifyUrl,
            hasHosted: records.contains { $0.isHost(personId) }
        )
    }

    func friends() async throws -> [Friend] {
        await pause()
        return MockRules.friends(of: currentUser.person, in: records)
    }

    func notifications() async throws -> [InboxNotification] {
        await pause()
        return backend.inboxes[personId, default: []].sorted { $0.createdAt > $1.createdAt }
    }

    func markNotificationRead(id: InboxNotification.ID) async throws {
        await pause()
        guard let index = backend.inboxes[personId]?.firstIndex(where: { $0.id == id }) else { return }
        backend.inboxes[personId]?[index].readAt = .now
    }

    // MARK: Events

    func events(_ list: EventListKind) async throws -> [Event] {
        await pause()
        let events = records
            .filter { MockRules.record($0, isIn: list, for: currentUser.person) }
            .map(resolved)
        return list == .past
            ? events.sorted { $0.startsAt > $1.startsAt }
            : events.sorted { $0.startsAt < $1.startsAt }
    }

    func event(id: Event.ID) async throws -> Event {
        await pause()
        return resolved(try record(id))
    }

    // MARK: Helpers

    /// The record for an event id, or `event_not_found`.
    func record(_ id: Event.ID) throws -> MockEventRecord {
        guard let record = records.first(where: { $0.id == id }) else { throw APIError.eventNotFound }
        return record
    }

    /// Replaces a stored record with a changed copy.
    func save(_ record: MockEventRecord) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index] = record
    }

    /// The record turned into the event `currentUser` sees.
    func resolved(_ record: MockEventRecord) -> Event {
        let friendIds = Set(MockRules.friends(of: currentUser.person, in: records).map(\.id))
        return MockRules.event(record, for: currentUser.person, friendIds: friendIds)
    }
}
