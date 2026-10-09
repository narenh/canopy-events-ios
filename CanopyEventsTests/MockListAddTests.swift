import Foundation
import Testing
@testable import CanopyEvents

/// Adding people to a list in the mock, against docs/api.md's "Adding
/// people": the owner only, verified only; you and the opted out skipped
/// and not added; again is `alreadyOn`; being added is joining (invited to
/// the list's events still to come); all or nothing at 1,000; and members
/// still never see each other. Maya owns Drag Race (on her finale) and
/// Climbing (on nothing); Rosa is a verified account with no lists.
@MainActor
struct MockListAddTests {
    let backend = MockBackend(delay: .zero)
    var maya: MockEventsRepository { MockEventsRepository(backend: backend, personId: MockPeople.maya.id) }
    var sam: MockEventsRepository { MockEventsRepository(backend: backend, personId: MockPeople.sam.id) }
    var rosa: MockEventsRepository { MockEventsRepository(backend: backend, personId: MockPeople.rosa.id) }
    private let p = MockPeople.self

    @Test func onlyAVerifiedOwnerAdds() async throws {
        let unverified = await #expect(throws: APIError.self) {
            try await sam.addListMembers(listId: MockLists.dragRaceId, personIds: [p.ana.id])
        }
        #expect(unverified?.reason == .emailUnverified)
        // Someone else's list, or none, is the same 404.
        for listId in [MockLists.dragRaceId, MockLists.dumplingCrewId, "LqNoSuchList"] {
            let error = await #expect(throws: APIError.self) { try await rosa.addListMembers(listId: listId, personIds: [p.ana.id]) }
            #expect(error?.reason == .listNotFound)
        }
        for ids in [[], Array(repeating: p.ana.id, count: 101)] {
            let error = await #expect(throws: APIError.self) { try await maya.addListMembers(listId: MockLists.climbingId, personIds: ids) }
            #expect(error?.reason == .badPersonIds)
        }
        #expect(backend.list(id: MockLists.climbingId)?.members.count == 5)
    }

    @Test func youTheUnknownAndTheOptedOutAreSkippedAndNotAdded() async throws {
        backend.inviteOptouts[p.ines.id] = [p.maya.id]
        let result = try await maya.addListMembers(listId: MockLists.climbingId,
                                                   personIds: [p.maya.id, "p-nobody", p.ines.id, p.theo.id, p.theo.id])
        #expect(result.added.map(\.id) == [p.theo.id])
        // The opted out read exactly like no account.
        #expect(result.skipped == [SkippedListAdd(personId: p.maya.id, reason: .isYou),
                                   SkippedListAdd(personId: "p-nobody", reason: .notFound),
                                   SkippedListAdd(personId: p.ines.id, reason: .notFound)])
        #expect(result.list.memberCount == 6 && result.alreadyOn.isEmpty)
        let members = try await maya.allListMembers(listId: MockLists.climbingId)
        #expect(!members.contains { $0.id == p.ines.id || $0.id == p.maya.id })
        #expect(members.first?.id == p.theo.id && members.first?.source == .added)
    }

    @Test func againIsAlreadyOnAndChangesNothing() async throws {
        let first = try await maya.addListMembers(listId: MockLists.dragRaceId, personIds: [p.sam.id])
        #expect(first.invitedTo == 1)
        let joinedAt = try #require(backend.list(id: MockLists.dragRaceId)?.members.first { $0.id == p.sam.id }?.joinedAt)
        let inbox = backend.inboxes[p.sam.id]?.count
        // Theo joined by the link: also "on it already", and still "link".
        let again = try await maya.addListMembers(listId: MockLists.dragRaceId, personIds: [p.sam.id, p.theo.id])
        #expect(again.added.isEmpty && again.alreadyOn == [p.sam.id, p.theo.id] && again.invitedTo == 0)
        #expect(again.list.memberCount == 21 && backend.inboxes[p.sam.id]?.count == inbox)
        let members = try await maya.allListMembers(listId: MockLists.dragRaceId)
        #expect(members.first { $0.id == p.sam.id }?.joinedAt == joinedAt)
        #expect(members.first { $0.id == p.theo.id }?.source == .link)
    }

    @Test func beingAddedIsJoining() async throws {
        let result = try await maya.addListMembers(listId: MockLists.dragRaceId, personIds: [p.sam.id])
        #expect(result.invitedTo == 1 && result.added.map(\.id) == [p.sam.id])
        let finale = try await sam.event(id: MockEvents.dragFinaleId)
        #expect(finale.myStatus == .invited)
        #expect(backend.inboxes[p.sam.id]?.contains { $0.type == .invited && $0.event?.id == MockEvents.dragFinaleId && $0.actor?.id == p.maya.id } == true)
        // The invitation made them friends; a list on nothing makes none.
        #expect(backend.friendEdges[p.maya.id]?[p.sam.id] == .invite)
        _ = try await maya.addListMembers(listId: MockLists.climbingId, personIds: [p.rosa.id])
        #expect(backend.friendEdges[p.maya.id]?[p.rosa.id] == nil)
    }

    @Test func eventsOverOrCancelledAreSkipped() async throws {
        let index = try #require(backend.records.firstIndex { $0.id == MockEvents.dragFinaleId })
        backend.records[index].event.status = .cancelled
        #expect(try await maya.addListMembers(listId: MockLists.dragRaceId, personIds: [p.sam.id]).invitedTo == 0)
        #expect(try await sam.event(id: MockEvents.dragFinaleId).myStatus == nil)
    }

    @Test func aThousandIsAllOrNothing() async throws {
        var list = try #require(backend.list(id: MockLists.climbingId))
        list.members += (list.members.count..<999).map {
            ListMember(person: Person(id: "p-fill\($0)", firstName: "Fill", lastName: "\($0)", shortName: "Fill", photoUrl: nil),
                       joinedAt: .now, source: .link)
        }
        backend.save(list)
        let full = await #expect(throws: APIError.self) {
            try await maya.addListMembers(listId: MockLists.climbingId, personIds: [p.theo.id, p.ines.id])
        }
        #expect(full?.reason == .listFull && backend.list(id: MockLists.climbingId)?.members.count == 999)
        #expect(try await maya.addListMembers(listId: MockLists.climbingId, personIds: [p.theo.id]).list.memberCount == 1000)
    }

    @Test func theAddedSeeOnlyTheListAndCanLeave() async throws {
        _ = try await maya.addListMembers(listId: MockLists.climbingId, personIds: [p.sam.id])
        let membership = try #require(try await sam.listMemberships().first { $0.id == MockLists.climbingId })
        #expect(membership.name == "Climbing" && membership.owner.id == p.maya.id)
        let error = await #expect(throws: APIError.self) { try await sam.listMembers(listId: MockLists.climbingId, page: .first) }
        #expect(error?.reason == .listNotFound)
        try await sam.leaveList(id: MockLists.climbingId)
        #expect(try await maya.addListMembers(listId: MockLists.climbingId, personIds: [p.sam.id]).added.count == 1)
    }

    @Test func joiningByTheLinkIsLinkAndTheSeedSaysHowEachCame() async throws {
        _ = try await sam.joinList(code: backend.list(id: MockLists.dragRaceId)!.code)
        let dragRace = try await maya.allListMembers(listId: MockLists.dragRaceId)
        #expect(dragRace.allSatisfy { $0.source == .link } && dragRace.first?.id == p.sam.id)
        #expect(try await maya.allListMembers(listId: MockLists.climbingId).allSatisfy { $0.source == .added })
    }
}
