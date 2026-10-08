import Foundation

/// The events API as one signed-in person sees it, answered from the
/// shared in-memory `MockBackend`. It applies the server's rules through
/// `MockRules`, so visibility, counts and the waitlist behave for real.
///
/// The rest is in the extensions next to this file: `+Hosting`, `+Covers`,
/// `+Guests`, `+GuestMenu`, `+Invites`, `+Hosts`, `+Moderation`, `+Wall`,
/// `+Notifications`, `+People`, `+Friends` and `+Settings`.
final class MockEventsRepository: EventsRepository {
    let backend: MockBackend
    let personId: Person.ID

    init(backend: MockBackend, personId: Person.ID) {
        self.backend = backend
        self.personId = personId
    }

    /// A repository with its own fresh backend, for previews and defaults.
    convenience init(signedInAs me: AccountProfile = MockPeople.maya, delay: Duration = .milliseconds(350)) {
        let backend = MockBackend(delay: delay)
        backend.save(me)
        self.init(backend: backend, personId: me.id)
    }

    /// You, as the backend has you now (verifying your email changes it).
    /// `me()` refuses unknown ids, so the Maya fallback is never shown.
    var currentUser: AccountProfile {
        backend.account(id: personId) ?? MockPeople.maya
    }

    var records: [MockEventRecord] {
        get { backend.records }
        set { backend.records = newValue }
    }

    func pause() async {
        await backend.pause()
    }

    // MARK: You

    func me() async throws -> MeEnvelope {
        await pause()
        guard backend.account(id: personId) != nil else {
            throw APIError.signInRequired
        }
        let verifyUrl = URL(string: "https://account.canopysf.com/profile?verify=1")
        return MeEnvelope(
            person: currentUser.me,
            verifyUrl: currentUser.emailVerified ? nil : verifyUrl,
            hasHosted: backend.hostedPeople.contains(personId)
        )
    }

    // MARK: Events

    func events(_ list: EventListKind, page: PageRequest) async throws -> EventList {
        await pause()
        let all = records
            .filter { MockRules.record($0, isIn: list, for: currentUser.person) }
            .sorted { list == .past ? $0.event.startsAt > $1.event.startsAt : $0.event.startsAt < $1.event.startsAt }
        let (page, next) = try MockPaging.page(all, page)
        return EventList(events: page.map { resolved($0, withFriends: false) }, nextCursor: next)
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

    /// A new 12-character base62 event id.
    func newEventId() -> Event.ID {
        String((0..<12).map { _ in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".randomElement()! })
    }

    /// Anyone the mock world knows: the sample people and every account.
    func knownPerson(_ id: Person.ID) -> Person? {
        backend.person(id)
    }

    /// Replaces a stored record with a changed copy.
    func save(_ record: MockEventRecord) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index] = record
    }

    /// The record turned into the event `currentUser` sees. Lists leave
    /// out `friendsGoing`; a single event has it.
    func resolved(_ record: MockEventRecord, withFriends: Bool = true) -> Event {
        let friendIds = Set(backend.friends(of: currentUser.person).map(\.id))
        var event = MockRules.event(record, for: currentUser.person, friendIds: friendIds)
        if !withFriends { event.friendsGoing = nil }
        return event
    }
}
