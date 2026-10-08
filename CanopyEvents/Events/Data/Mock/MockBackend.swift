import Foundation

/// The mock "server": every account, event, wall post and inbox, in
/// memory. One instance is shared by `MockAccountService` and every
/// `MockEventsRepository`, so a change made as one person (an invite, an
/// RSVP) is there when someone else signs in, until the app quits.
final class MockBackend {
    var accounts: [AccountProfile]
    var records: [MockEventRecord]
    /// Each event's wall, by event id, in the order entries were made.
    var wall: [Event.ID: [WallEntry]]
    var inboxes: [Person.ID: [InboxNotification]]
    /// Everyone who has ever hosted or co-hosted (`hasHosted` stays true
    /// once it is, even after an event is deleted or they step down).
    var hostedPeople: Set<Person.ID>
    /// Friends added by hand, linked or invited, by whose list they're
    /// in: one way unless both sides have the other.
    var friendEdges: [Person.ID: [Person.ID: FriendSource]] = [:]
    /// When each of those edges was made, for the suggestions' score.
    var friendEdgeDates: [Person.ID: [Person.ID: Date]] = [:]
    /// Every list, in the order made.
    var lists: [MockListRecord]
    /// People someone took out of their list: they stay out until added again.
    var removedFriends: [Person.ID: Set<Person.ID>] = [:]
    /// Friend link codes, by whose they are.
    var friendLinks: [Person.ID: String] = [:]
    /// Whose invitations someone opted out of, oldest first.
    var inviteOptouts: [Person.ID: [Person.ID]] = [:]
    /// Settings, by whose they are; missing means the defaults.
    var settings: [Person.ID: Settings] = [:]
    /// Push tokens, by whose they are (up to 10 each).
    var devices: [Person.ID: [String]] = [:]
    private let delay: Duration
    private var lastId = MockWall.firstNewId

    /// Seeded with the sample data in `MockData/`. `delay` is the fake
    /// network time every call waits; previews pass `.zero`.
    init(delay: Duration = .milliseconds(350)) {
        self.accounts = [MockPeople.maya, MockPeople.sam, MockPeople.rosaAccount]
        self.records = MockEvents.all
        self.lists = MockLists.all
        self.inviteOptouts = MockLists.optouts
        self.wall = MockWall.entries
        self.hostedPeople = Set(MockEvents.all.flatMap { $0.event.hosts.map(\.person.id) })
        self.inboxes = [
            MockPeople.maya.id: MockNotifications.inbox(for: MockPeople.maya.id),
            MockPeople.sam.id: MockNotifications.inbox(for: MockPeople.sam.id),
        ]
        self.delay = delay
        inviteSeedLists()
    }

    /// The artificial network delay. Every mock call awaits it first.
    func pause() async {
        try? await Task.sleep(for: delay)
    }

    /// A new numeric id, for wall entries and notifications (the API's are digits).
    func nextId() -> String {
        lastId += 1
        return String(lastId)
    }

    func account(id: Person.ID) -> AccountProfile? {
        accounts.first { $0.id == id }
    }

    func account(email: String) -> AccountProfile? {
        accounts.first { $0.email.caseInsensitiveCompare(email) == .orderedSame }
    }

    /// Adds the account, or replaces the one with the same id.
    func save(_ account: AccountProfile) {
        accounts.removeAll { $0.id == account.id }
        accounts.append(account)
    }

    /// Puts an entry in someone's inbox (the real server also pushes it).
    /// Nobody is told of their own doing. An `rsvp` folds into the unread
    /// one for the same event: the count goes up and the actor is the newest.
    func notify(
        _ personId: Person.ID, _ type: NotificationType, about event: Event,
        from actor: Person?, details: NotificationDetails? = nil
    ) {
        guard personId != actor?.id else { return }
        // Muted: the chatter skips the inbox; the essentials still come.
        if [.wallPost, .rsvp, .cohostAdded].contains(type),
           records.first(where: { $0.id == event.id })?.mutedIds.contains(personId) == true { return }
        var inbox = inboxes[personId, default: []]
        if type == .rsvp, let index = inbox.firstIndex(where: { $0.type == .rsvp && !$0.read && $0.event?.id == event.id }) {
            inbox[index].count += 1
            inbox[index].actor = actor
            inbox[index].details = details
            inbox[index].createdAt = .now
        } else {
            inbox.append(InboxNotification(
                id: nextId(), type: type, createdAt: .now, read: false, actor: actor,
                event: EventSummary(event: event), details: details, count: 1
            ))
        }
        inboxes[personId] = inbox
    }
}
