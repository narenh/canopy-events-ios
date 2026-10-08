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
        let upcoming = try await repository.allEvents(.upcoming)
        #expect(upcoming.allSatisfy { $0.viewer?.isHost != true && $0.friendsGoing == nil })
        #expect(try await repository.allEvents(.hosting).count == 2)
        #expect(try await repository.allEvents(.invitations).map(\.id).sorted() == [MockEvents.hikeId, MockEvents.potteryId].sorted())
        #expect(try await repository.allEvents(.declined).map(\.id) == [MockEvents.triviaId])
    }

    @Test func answeringRevealsAHiddenGuestListAndMovesTheInvite() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        #expect(try await repository.wholeGuestList(eventId: MockEvents.hikeId).guestsVisible == false)
        #expect(try await repository.wall(eventId: MockEvents.hikeId, page: .first).wallVisible == false)
        let hike = try await repository.setRSVP(eventId: MockEvents.hikeId, status: .maybe, guests: 0)
        #expect(hike.event.myStatus == .maybe && hike.event.viewer?.canPost == true)
        #expect(try await repository.wholeGuestList(eventId: MockEvents.hikeId).guestsVisible)
        #expect(try await repository.allEvents(.upcoming).contains { $0.id == MockEvents.hikeId })
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
        #expect(supper.waitlisted && supper.event.myStatus == .waitlisted)
        #expect(supper.event.counts.total.going == 8 && supper.event.spotsLeft == 0)
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
        #expect(try await session.repository.allEvents(.hosting).map(\.id) == [created.id])
    }

    @Test func hostsInviteFriendsAndSkipPeopleAlreadyOnTheList() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let friends = try await repository.allFriends()
        let result = try await repository.invite(eventId: MockEvents.gameNightId, personIds: friends.map(\.id))
        #expect(!result.invited.isEmpty)
        #expect(result.skipped.contains { $0.personId == MockPeople.ben.id && $0.reason == .alreadyOnList })
    }

    @Test func changesSurviveSigningOutAndBackIn() async throws {
        try await session.signInWithPasskey()
        _ = try await session.repository.postToWall(eventId: MockEvents.rooftopId, text: "Bringing bread")
        await session.signOut()
        #expect(!session.isSignedIn)
        try await session.signInWithPasskey()
        let wall = try await session.repository.wall(eventId: MockEvents.rooftopId, page: .first)
        #expect(wall.entries.contains { $0.text == "Bringing bread" && $0.canDelete })
    }

    @Test func signingInByCodeVerifiesAQuickAccount() async throws {
        try await session.sendSignInCode(to: "sam@example.com")
        let proven = try await session.checkSignInCode("123456")
        #expect(proven.state == .existing && proven.unverified == true)
        try await session.signInWithNewPasskey()
        #expect(session.me?.id == MockPeople.sam.id && !session.needsVerification)
    }

    @Test func listsPageWithCursors() async throws {
        try await session.signInWithPasskey()
        let first = try await session.repository.events(.upcoming, page: PageRequest(limit: 2))
        let cursor = try #require(first.nextCursor)
        let second = try await session.repository.events(.upcoming, page: .after(cursor, limit: 2))
        #expect(Set(first.events.map(\.id)).isDisjoint(with: second.events.map(\.id)))
    }
}
