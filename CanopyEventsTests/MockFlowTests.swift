import Foundation
import Testing
@testable import CanopyEvents

/// End-to-end checks of the mock world, driven through `AppSession` and
/// the repository the way the screens call them. Not in a target yet:
/// add a unit test target named CanopyEventsTests in Xcode and this
/// folder becomes its sources (see ARCHITECTURE.md, "Tests").
@MainActor
struct MockFlowTests {
    let session = AppSession.mock(delay: .zero)

    @Test func passkeySignInIsMayaAndAHost() async throws {
        try await session.signInWithPasskey()
        #expect(session.me?.id == MockPeople.maya.id)
        #expect(session.isHost)
        #expect(!session.needsVerification)
    }

    @Test func listsAreSplitWithoutDuplicates() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let upcoming = try await repository.events(.upcoming)
        #expect(upcoming.allSatisfy { $0.viewer?.isHost != true })
        #expect(try await repository.events(.hosting).count == 2)
        #expect(try await repository.events(.invitations).map(\.id).sorted() == [MockEvents.hikeId, MockEvents.potteryId].sorted())
        #expect(try await repository.events(.declined).map(\.id) == [MockEvents.triviaId])
    }

    @Test func answeringRevealsAHiddenGuestListAndMovesTheInvite() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        #expect(try await repository.guestList(eventId: MockEvents.hikeId).guestsVisible == false)
        let hike = try await repository.setRSVP(eventId: MockEvents.hikeId, status: .maybe, guests: 0)
        #expect(hike.myStatus == .maybe)
        #expect(try await repository.guestList(eventId: MockEvents.hikeId).guestsVisible)
        #expect(try await repository.events(.upcoming).contains { $0.id == MockEvents.hikeId })
    }

    @Test func plusOnesAreCappedByTheHost() async throws {
        try await session.signInWithPasskey()
        let error = await #expect(throws: APIError.self) {
            try await session.repository.setRSVP(eventId: MockEvents.rooftopId, status: .going, guests: 3)
        }
        #expect(error?.reason == .tooManyGuests)
    }

    @Test func goingToAFullEventWaitlists() async throws {
        try await session.quickSignUp(firstName: "Ada", lastName: "Ng", email: "ada@example.com")
        let supper = try await session.repository.setRSVP(eventId: MockEvents.supperClubId, status: .going, guests: 0)
        #expect(supper.myStatus == .waitlisted)
    }

    @Test func aFreedSpotPromotesTheEarliestWaitlisted() throws {
        var record = try #require(MockEvents.all.first { $0.id == MockEvents.supperClubId })
        record.event.capacity = 9
        MockRules.promoteWaitlist(&record)
        #expect(record.guest(MockPeople.maya.id)?.status == .going)
        #expect(record.guest(MockPeople.gus.id)?.status == .waitlisted)
    }

    @Test func quickAccountsVerifyAndBecomeHostsWithTheirFirstEvent() async throws {
        try await session.quickSignUp(firstName: "Ada", lastName: "Ng", email: "ada@example.com")
        #expect(session.needsVerification)
        #expect(!session.isHost)
        await #expect(throws: APIError.self) { try await session.repository.createEvent(.blank()) }

        try await session.verifyEmail(code: "123456")
        #expect(!session.needsVerification)

        var draft = EventDraft.blank()
        draft.title = "Ada's first party"
        let created = try await session.repository.createEvent(draft)
        try await session.refresh()
        #expect(session.isHost)
        #expect(try await session.repository.events(.hosting).map(\.id) == [created.id])
    }

    @Test func hostsInviteFriendsAndSkipPeopleAlreadyOnTheList() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let friends = try await repository.friends()
        let result = try await repository.invite(eventId: MockEvents.gameNightId, personIds: friends.map(\.id))
        #expect(!result.invited.isEmpty)
        #expect(result.skipped.contains { $0.personId == MockPeople.ben.id && $0.reason == "already_on_list" })
    }

    @Test func changesSurviveSigningOutAndBackIn() async throws {
        try await session.signInWithPasskey()
        _ = try await session.repository.addWallPost(eventId: MockEvents.rooftopId, body: "Bringing bread")
        await session.signOut()
        #expect(!session.isSignedIn)
        try await session.signInWithPasskey()
        #expect(try await session.repository.wallPosts(eventId: MockEvents.rooftopId).contains { $0.body == "Bringing bread" })
    }
}
