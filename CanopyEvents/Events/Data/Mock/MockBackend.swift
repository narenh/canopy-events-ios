import Foundation

/// The mock "server": every account, event, wall post and inbox, in
/// memory. One instance is shared by `MockAuthService` and every
/// `MockEventsRepository`, so a change made as one person (an invite, an
/// RSVP) is there when someone else signs in, until the app quits.
final class MockBackend {
    var accounts: [Me]
    var records: [MockEventRecord]
    var posts: [WallPost]
    var inboxes: [Person.ID: [InboxNotification]]
    private let delay: Duration

    /// Seeded with the sample data in `MockData/`. `delay` is the fake
    /// network time every call waits; previews pass `.zero`.
    init(delay: Duration = .milliseconds(350)) {
        self.accounts = [MockPeople.maya, MockPeople.sam]
        self.records = MockEvents.all
        self.posts = MockWallPosts.all
        self.inboxes = [
            MockPeople.maya.id: MockNotifications.inbox(for: MockPeople.maya.id),
            MockPeople.sam.id: MockNotifications.inbox(for: MockPeople.sam.id),
        ]
        self.delay = delay
    }

    /// The artificial network delay. Every mock call awaits it first.
    func pause() async {
        try? await Task.sleep(for: delay)
    }

    func account(id: Person.ID) -> Me? {
        accounts.first { $0.id == id }
    }

    func account(email: String) -> Me? {
        accounts.first { $0.email?.caseInsensitiveCompare(email) == .orderedSame }
    }

    /// Adds the account, or replaces the one with the same id.
    func save(_ account: Me) {
        accounts.removeAll { $0.id == account.id }
        accounts.append(account)
    }

    /// Puts an entry in someone's inbox (the real server also sends a push).
    func notify(_ personId: Person.ID, _ kind: NotificationKind, about event: Event, from actor: Person) {
        let item = InboxNotification(
            id: UUID().uuidString, kind: kind, eventId: event.id, eventTitle: event.title,
            actor: actor, createdAt: .now, readAt: nil
        )
        inboxes[personId, default: []].append(item)
    }
}
