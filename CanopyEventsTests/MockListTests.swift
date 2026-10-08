import Foundation
import Testing
@testable import CanopyEvents

/// Lists in the mock, against docs/api.md's "Lists": privacy, joining
/// (never your own; it invites you to the list's events still to come),
/// putting a list on an event (it invites everyone on it but opt-outs),
/// and what an event says about its lists. Maya owns Drag Race and
/// Climbing; Ana owns Dumpling crew (on her rooftop dinner and Dumpling
/// night II); Sam is the second account.
@MainActor
struct MockListTests {
    let backend = MockBackend(delay: .zero)
    var maya: MockEventsRepository { MockEventsRepository(backend: backend, personId: MockPeople.maya.id) }
    var sam: MockEventsRepository { MockEventsRepository(backend: backend, personId: MockPeople.sam.id) }

    private func code(_ listId: String) -> String {
        backend.list(id: listId)!.code
    }

    @Test func onlyTheOwnerSeesWhoIsOnAList() async throws {
        let members = try await maya.allListMembers(listId: MockLists.dragRaceId)
        #expect(members.count == 20)
        #expect(members.map(\.joinedAt) == members.map(\.joinedAt).sorted(by: >))
        #expect(try await maya.lists().map(\.name) == ["Drag Race", "Climbing"])

        _ = try await sam.joinList(code: code(MockLists.dragRaceId))
        let membership = try #require(try await sam.listMemberships().first)
        #expect(membership.name == "Drag Race" && membership.owner.id == MockPeople.maya.id)
        // A member gets 404 on every owner call, like someone who isn't on it.
        for call in [
            { _ = try await sam.listMembers(listId: MockLists.dragRaceId, page: .first) },
            { _ = try await sam.renameList(id: MockLists.dragRaceId, name: "Mine now") },
            { try await sam.deleteList(id: MockLists.dragRaceId) },
            { _ = try await sam.attachList(eventId: MockEvents.gameNightId, listId: MockLists.dragRaceId) },
        ] as [() async throws -> Void] {
            let error = await #expect(throws: APIError.self) { try await call() }
            #expect(error?.reason == .listNotFound || error?.reason == .hostsOnly)
        }
        #expect(try await sam.lists().isEmpty)
        #expect(try await maya.listMembers(listId: MockLists.dragRaceId, page: .first).members.first?.id == MockPeople.sam.id)
    }

    @Test func joiningYourOwnListFails() async throws {
        let link = try await maya.listLink(code: code(MockLists.dragRaceId))
        #expect(link.viewer?.isOwner == true && link.list.name == "Drag Race")
        let error = await #expect(throws: APIError.self) { try await maya.joinList(code: code(MockLists.dragRaceId)) }
        #expect(error?.reason == .ownList)
        let wrong = await #expect(throws: APIError.self) { try await maya.listLink(code: "nope00000000") }
        #expect(wrong?.reason == .listLinkNotFound)
    }

    @Test func openingALinkJoinsNobodyAndJoiningInvitesToWhatsComing() async throws {
        let rooftop = try await maya.event(id: MockEvents.rooftopId)
        let joinable = try #require(rooftop.joinableList)
        #expect(joinable.code == MockLists.dumplingCrewCode && joinable.owner.id == MockPeople.ana.id)
        #expect(rooftop.hostLists == nil)
        #expect(try await maya.listLink(code: joinable.code).viewer?.isMember == false)
        #expect(!backend.list(id: MockLists.dumplingCrewId)!.hasMember(MockPeople.maya.id))

        // Going to the rooftop already, so only Dumpling night II is new.
        let joined = try await maya.joinList(code: joinable.code)
        #expect(joined.invitedTo == 1 && joined.list.owner.id == MockPeople.ana.id)
        #expect(try await maya.allEvents(.invitations).contains { $0.id == MockEvents.dumplingTwoId })
        #expect(try await maya.event(id: MockEvents.rooftopId).joinableList == nil)
        #expect(backend.inboxes[MockPeople.maya.id]?.contains { $0.type == .invited && $0.event?.id == MockEvents.dumplingTwoId } == true)
        // Again changes nothing.
        #expect(try await maya.joinList(code: joinable.code).invitedTo == 0)
    }

    @Test func joiningSkipsEventsThatAreOverOrCancelled() async throws {
        let index = try #require(backend.records.firstIndex { $0.id == MockEvents.dumplingTwoId })
        backend.records[index].event.status = .cancelled
        #expect(try await maya.joinList(code: MockLists.dumplingCrewCode).invitedTo == 0)
    }

    @Test func attachingInvitesEveryoneOnItButOptOuts() async throws {
        // Drag Race's 20, less Ben and Kofi (on game night already) and
        // Zane (opted out of Maya's invitations).
        let attached = try await maya.attachList(eventId: MockEvents.gameNightId, listId: MockLists.dragRaceId)
        #expect(attached.invitedCount == 17)
        let guests = try await maya.wholeGuestList(eventId: MockEvents.gameNightId).guests
        #expect(!guests.contains { $0.id == MockPeople.zane.id })
        #expect(guests.contains { $0.id == MockPeople.theo.id && $0.status == .invited })
        let onEvent = try #require(attached.event.hostLists?.first)
        #expect(onEvent.isYours && onEvent.memberCount == 20 && onEvent.name == "Drag Race")
        // Again: nobody new.
        #expect(try await maya.attachList(eventId: MockEvents.gameNightId, listId: MockLists.dragRaceId).invitedCount == 0)
        // Someone else's list is a 404.
        let error = await #expect(throws: APIError.self) {
            try await maya.attachList(eventId: MockEvents.gameNightId, listId: MockLists.dumplingCrewId)
        }
        #expect(error?.reason == .listNotFound)
        // Taking it off changes nobody's invitation.
        let detached = try await maya.detachList(eventId: MockEvents.gameNightId, listId: MockLists.dragRaceId)
        #expect(detached.hostLists?.isEmpty == true)
        #expect(try await maya.wholeGuestList(eventId: MockEvents.gameNightId).guests.count == guests.count)
    }

    @Test func anOptedOutJoinerIsOnTheListAndNothingElse() async throws {
        try await sam.optOutOfInvites(from: MockPeople.maya.id)
        let joined = try await sam.joinList(code: code(MockLists.dragRaceId))
        #expect(joined.invitedTo == 0)
        #expect(try await maya.allListMembers(listId: MockLists.dragRaceId).count == 21)
        #expect(try await !maya.wholeGuestList(eventId: MockEvents.dragFinaleId).guests.contains { $0.id == MockPeople.sam.id })
    }

    @Test func aJoinerIsInvitedToTheOwnersAttachedEvents() async throws {
        let joined = try await sam.joinList(code: code(MockLists.dragRaceId))
        #expect(joined.invitedTo == 1)
        let finale = try await sam.event(id: MockEvents.dragFinaleId)
        #expect(finale.myStatus == .invited && finale.hostLists == nil && finale.joinableList == nil)
    }

    @Test func hostsGetHostListsAndGuestsGetAJoinableList() async throws {
        let finale = try await maya.event(id: MockEvents.dragFinaleId)
        #expect(finale.hostLists?.map(\.name) == ["Drag Race"] && finale.joinableList == nil)
        #expect(try await sam.event(id: MockEvents.dragFinaleId).joinableList?.name == "Drag Race")
        // Lists of events never carry them.
        #expect(try await maya.allEvents(.hosting).allSatisfy { $0.hostLists == nil && $0.joinableList == nil })
    }

    @Test func renameResetRemoveLeaveAndDelete() async throws {
        let old = code(MockLists.climbingId)
        #expect(try await maya.renameList(id: MockLists.climbingId, name: "  Climbing   crew ").name == "Climbing crew")
        let reset = try await maya.resetListLink(id: MockLists.climbingId)
        #expect(reset.code != old && reset.url.hasSuffix(reset.code) && reset.memberCount == 5)
        await #expect(throws: APIError.self) { try await sam.listLink(code: old) }
        try await maya.removeListMember(listId: MockLists.climbingId, personId: MockPeople.ana.id)
        #expect(try await maya.lists().first { $0.id == MockLists.climbingId }?.memberCount == 4)

        #expect(try await maya.listMemberships().map(\.name) == ["Supper club"])
        try await maya.leaveList(id: MockLists.supperClubId)
        #expect(try await maya.listMemberships().isEmpty)

        _ = try await maya.attachList(eventId: MockEvents.gameNightId, listId: MockLists.climbingId)
        try await maya.deleteList(id: MockLists.climbingId)
        #expect(try await maya.event(id: MockEvents.gameNightId).hostLists?.isEmpty == true)
        let bad = await #expect(throws: APIError.self) { try await maya.createList(name: "   ") }
        #expect(bad?.reason == .badName)
        let unverified = await #expect(throws: APIError.self) { try await sam.createList(name: "Sam's") }
        #expect(unverified?.reason == .emailUnverified)
    }

    @Test func suggestionsAreScoredBestFirst() async throws {
        let suggested = try await maya.suggestedFriends(limit: 50)
        #expect(suggested.allSatisfy { $0.score > 0 })
        #expect(suggested.map(\.score) == suggested.map(\.score).sorted(by: >))
        // Jules: two Drag Race nights and the bonfire, all Maya's (double),
        // and an invitation; Ben next, with the dumpling night as a guest.
        #expect(suggested.prefix(2).map(\.id) == [MockPeople.jules.id, MockPeople.ben.id])
        // A tie goes to whoever you were with last, then by id.
        let tied = suggested.filter { $0.score == suggested[2].score }.map(\.id)
        #expect(tied.count > 1 && tied == tied.sorted())
        // Isaac: one book club two months ago, as a guest: 2^(-60/90).
        let isaac = try #require(suggested.first { $0.id == MockPeople.isaac.id })
        #expect(abs(isaac.score - pow(2, -60.0 / 90)) < 0.01)
        #expect(try await maya.suggestedFriends(limit: 8).count == 8)
        await #expect(throws: APIError.self) { try await maya.suggestedFriends(limit: 51) }
    }

    @Test func fadingHalvesEveryNinetyDays() {
        let now = Date.now
        #expect(MockBackend.fading(since: now, now: now) == 1)
        #expect(abs(MockBackend.fading(since: now.addingTimeInterval(-90 * 86_400), now: now) - 0.5) < 1e-9)
    }
}
