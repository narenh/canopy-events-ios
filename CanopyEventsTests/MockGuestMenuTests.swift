import Foundation
import Testing
@testable import CanopyEvents

/// The guest menu, friends, settings, details and the All list, as the
/// mock applies the API's rules.
@MainActor
struct MockGuestMenuTests {
    let session = AppSession.mock(delay: .zero)

    @Test func mutingSkipsTheChatterButNotTheEssentials() async throws {
        try await session.signInWithPasskey()
        let maya = session.repository
        #expect(try await maya.muteEvent(id: MockEvents.rooftopId).viewer?.muted == true)
        let error = await #expect(throws: APIError.self) { try await maya.muteEvent(id: MockEvents.gameNightId) }
        #expect(error?.reason == .isHost)
        #expect(try await maya.unmuteEvent(id: MockEvents.rooftopId).viewer?.muted == false)
    }

    @Test func leavingTakesYouOffAndTheLinkStillWorks() async throws {
        try await session.signInWithPasskey()
        let maya = session.repository
        let after = try await maya.leaveEvent(id: MockEvents.rooftopId)
        #expect(after.viewer?.rsvp == nil)
        #expect(try await !maya.allEvents(.upcoming).contains { $0.id == MockEvents.rooftopId })
        let again = await #expect(throws: APIError.self) { try await maya.leaveEvent(id: MockEvents.rooftopId) }
        #expect(again?.reason == .notOnEvent)
        // Answering again, as anyone with the link could.
        #expect(try await maya.setRSVP(eventId: MockEvents.rooftopId, status: .maybe, guests: 0).event.myStatus == .maybe)
    }

    @Test func optingOutSkipsTheHostsInvitesAsNotFound() async throws {
        let backend = MockBackend(delay: .zero)
        let sam = MockEventsRepository(backend: backend, personId: MockPeople.sam.id)
        let maya = MockEventsRepository(backend: backend, personId: MockPeople.maya.id)
        try await sam.optOutOfInvites(from: MockPeople.maya.id)
        #expect(try await sam.inviteOptouts().hosts.map(\.id) == [MockPeople.maya.id])
        let result = try await maya.invite(eventId: MockEvents.gameNightId, personIds: [MockPeople.sam.id])
        #expect(result.skipped.first?.reason == .notFound && result.invited.isEmpty)
        try await sam.optInToInvites(from: MockPeople.maya.id)
        #expect(try await maya.invite(eventId: MockEvents.gameNightId, personIds: [MockPeople.sam.id]).invited.count == 1)
        // An invitation makes friends both ways.
        #expect(try await sam.allFriends().contains { $0.id == MockPeople.maya.id && $0.source == .invite })
    }

    @Test func friendsAddedLinkedAndTakenOut() async throws {
        let backend = MockBackend(delay: .zero)
        let maya = MockEventsRepository(backend: backend, personId: MockPeople.maya.id)
        let sam = MockEventsRepository(backend: backend, personId: MockPeople.sam.id)
        let added = try await maya.addFriend(personId: MockPeople.lena.id)
        #expect(added.source == .added || added.source == .sharedEvents)
        let added2 = try await maya.addFriend(personId: MockPeople.adam.id)
        #expect(added2.eventsInCommon == 0 && added2.lastTogetherAt == nil && added2.source == .added)
        try await maya.removeFriend(personId: MockPeople.ana.id)
        #expect(try await !maya.allFriends().contains { $0.id == MockPeople.ana.id })
        let link = try await maya.friendLink()
        #expect(link.url.hasSuffix(link.code))
        #expect(try await sam.friendLinkOwner(code: link.code).viewer?.isFriend == false)
        _ = try await sam.acceptFriendLink(code: link.code)
        #expect(try await maya.allFriends().contains { $0.id == MockPeople.sam.id && $0.source == .link })
        let own = await #expect(throws: APIError.self) { try await maya.acceptFriendLink(code: link.code) }
        #expect(own?.reason == .ownLink)
        let fresh = try await maya.resetFriendLink()
        await #expect(throws: APIError.self) { try await sam.friendLinkOwner(code: link.code) }
        #expect(fresh.code != link.code)
    }

    @Test func settingsDefaultOnAndChange() async throws {
        try await session.signInWithPasskey()
        #expect(try await session.repository.settings().calendarInvites)
        #expect(try await !session.repository.updateSettings(calendarInvites: false).calendarInvites)
        #expect(try await !session.repository.settings().calendarInvites)
    }

    @Test func detailsAreCheckedAndTidied() async throws {
        try await session.signInWithPasskey()
        var draft = EventDraft.blank()
        draft.title = "Picnic"
        draft.details = [EventDetailInput(type: .link, value: "partiful.com/e/x"),
                         EventDetailInput(type: .phone, label: "Ana", value: "(415) 555-0142")]
        let event = try await session.repository.createEvent(draft)
        #expect(event.details.map(\.href) == ["https://partiful.com/e/x", "tel:4155550142"])
        draft.details = [EventDetailInput(type: .info, value: "fine"), EventDetailInput(type: .link, value: "javascript:alert(1)")]
        let error = await #expect(throws: APIError.self) { try await session.repository.createEvent(draft) }
        #expect(error?.reason == .badDetailURL && error?.index == 1)
        draft.details = []
        draft.accentHue = 30
        let grey = await #expect(throws: APIError.self) { try await session.repository.createEvent(draft) }
        #expect(grey?.reason == .accentNeedsGrayscale)
    }

    @Test func allIsHostingUpcomingAndInvitationsOnce() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let all = Set(try await repository.allEvents(.all).map(\.id))
        var parts = Set<Event.ID>()
        for list in [EventListKind.hosting, .upcoming, .invitations] {
            parts.formUnion(try await repository.allEvents(list).map(\.id))
        }
        #expect(all == parts)
        #expect(!all.contains(MockEvents.triviaId))
    }
}
