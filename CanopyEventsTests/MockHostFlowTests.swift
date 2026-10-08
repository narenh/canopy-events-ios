import Foundation
import Testing
@testable import CanopyEvents

/// The mock's host-side rules: co-hosts, removing people, new links,
/// notifications and lookup. Not in a target yet, like `MockFlowTests`.
@MainActor
struct MockHostFlowTests {
    let session = AppSession.mock(delay: .zero)

    @Test func becomingACohostReplacesTheAnswerAndSteppingDownLeavesYouInvited() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let event = try await repository.addCohost(eventId: MockEvents.gameNightId, personId: MockPeople.ben.id)
        #expect(event.hosts.contains { $0.person.id == MockPeople.ben.id && $0.role == .cohost })
        // Ben's spot went to Gus, first on the waitlist.
        #expect(event.counts.going == 5 && event.counts.waitlisted == 1)
        let after = try await repository.removeCohost(eventId: MockEvents.gameNightId, personId: MockPeople.ben.id)
        #expect(after.counts.invited == 1)
    }

    @Test func removingSomeoneFreesTheirSpotAndHidesThem() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        try await repository.removeGuest(eventId: MockEvents.gameNightId, personId: MockPeople.diego.id)
        let list = try await repository.wholeGuestList(eventId: MockEvents.gameNightId)
        #expect(!list.guests.contains { $0.person.id == MockPeople.diego.id })
        #expect(list.guests(with: .going).contains { $0.person.id == MockPeople.gus.id })
        let removed = try await repository.guestList(eventId: MockEvents.gameNightId, status: .removed, page: .first)
        #expect(removed.guests.map(\.person.id) == [MockPeople.diego.id])
        let result = try await repository.invite(eventId: MockEvents.gameNightId, personIds: [MockPeople.diego.id])
        #expect(result.skipped.first?.reason == .removed)
    }

    @Test func aNewLinkMovesTheEvent() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let moved = try await repository.makeNewLink(eventId: MockEvents.gameNightId)
        #expect(moved.id != MockEvents.gameNightId)
        let error = await #expect(throws: APIError.self) { try await repository.event(id: MockEvents.gameNightId) }
        #expect(error?.reason == .eventNotFound)
        #expect(try await repository.allEvents(.hosting).contains { $0.id == moved.id })
    }

    @Test func coHostsCantCancel() async throws {
        let backend = MockBackend(delay: .zero)
        let p = MockPeople.ben
        backend.save(MockPeople.quickUser(id: p.id, firstName: p.firstName, lastName: p.lastName, email: "ben@example.com"))
        let ben = MockEventsRepository(backend: backend, personId: p.id)
        let error = await #expect(throws: APIError.self) { try await ben.cancelEvent(id: MockEvents.birthdayId) }
        #expect(error?.reason == .creatorOnly)
    }

    @Test func answersFoldIntoOneUnreadNotification() async throws {
        let backend = MockBackend(delay: .zero)
        _ = try await MockEventsRepository(backend: backend, personId: MockPeople.sam.id)
            .setRSVP(eventId: MockEvents.gameNightId, status: .maybe, guests: 0)
        let maya = MockEventsRepository(backend: backend, personId: MockPeople.maya.id)
        let inbox = try await maya.notifications(page: .first)
        let rsvp = try #require(inbox.notifications.first { $0.type == .rsvp && !$0.read })
        #expect(rsvp.count == 4 && rsvp.actor?.id == MockPeople.sam.id && rsvp.details?.status == .maybe)
        #expect(try await maya.markAllNotificationsRead() == 0)
    }

    @Test func lookupFindsExactMatchesOnly() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        #expect(try await repository.lookUpPerson(.phone("(415) 555-0123"))?.id == MockPeople.maya.id)
        #expect(try await repository.lookUpPerson(.instagram("@Maya.Chen"))?.id == MockPeople.maya.id)
        #expect(try await repository.lookUpPerson(.instagram("maya")) == nil)
    }

    @Test func onlyTheCreatorDeletesAndHostingStaysTrue() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        try await repository.deleteEvent(id: MockEvents.gameNightId)
        try await repository.deleteEvent(id: MockEvents.birthdayId)
        try await repository.deleteEvent(id: MockEvents.dragFinaleId)
        let error = await #expect(throws: APIError.self) { try await repository.event(id: MockEvents.gameNightId) }
        #expect(error?.reason == .eventNotFound)
        #expect(try await repository.allEvents(.hosting).isEmpty)
        #expect(try await repository.me().hasHosted)
        #expect(try await repository.wall(eventId: MockEvents.rooftopId, page: .first).wallVisible)
    }

    @Test func onlyHostsSeeTheInvitedCount() async throws {
        try await session.signInWithPasskey()
        #expect(try await session.repository.event(id: MockEvents.birthdayId).counts.invited == 2)
        #expect(try await session.repository.event(id: MockEvents.rooftopId).counts.invited == nil)
    }
}
