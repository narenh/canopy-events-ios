import Foundation
import Testing
@testable import CanopyEvents

/// The invite sheet's picking and order (`InvitePicker`), the web's
/// `inviteOrder`, `listPickable`, "Invite all <n>" and "Filter by past
/// event".
struct InvitePickerTests {
    private let p = MockPeople.self

    private func picker() -> InvitePicker {
        var picker = InvitePicker()
        picker.me = MockPeople.maya.id
        for person in [p.ana, p.ben, p.chloe, p.diego, p.elif, p.farah, p.gus, p.hana, p.isaac, p.jules, p.ines, p.theo] {
            picker.add(person, detail: "")
        }
        picker.lists = [InvitePicker.PickList(id: "L", name: "Drag Race", memberIds: [p.theo.id, p.ines.id, p.ben.id, p.jules.id])]
        picker.onEvent = [p.ben.id: .rsvp(.going), p.chloe.id: .hosting]
        return picker
    }

    @Test func inviteAllPicksWhoIsntOnTheEventAndCanBeUntickedOneByOne() {
        var picker = picker()
        let list = picker.lists[0]
        #expect(picker.pickable(in: list) == [p.theo.id, p.ines.id, p.jules.id])
        picker.toggleAll(in: list)
        #expect(picker.selected == [p.theo.id, p.ines.id, p.jules.id] && picker.isAllPicked(list))
        #expect(!picker.isPicked(p.ben.id))
        picker.toggle(p.ines.id)
        #expect(!picker.isAllPicked(list) && picker.selected == [p.theo.id, p.jules.id])
        // Not all picked: it picks the rest; all picked: it unpicks them.
        picker.toggleAll(in: list)
        #expect(picker.isAllPicked(list) && picker.selected.count == 3)
        picker.toggle(p.ana.id)
        picker.toggleAll(in: list)
        #expect(picker.selected == [p.ana.id])
    }

    @Test func peopleOnTheEventAndYouCantBePicked() {
        var picker = picker()
        picker.setPicked([p.ben.id, p.chloe.id, MockPeople.maya.id, p.ana.id], true)
        #expect(picker.selected == [p.ana.id])
        picker.add(MockPeople.maya.person, detail: "")
        #expect(picker.people[MockPeople.maya.id] == nil)
    }

    @Test func theTrayIsNewestFirst() {
        var picker = picker()
        picker.toggle(p.ana.id)
        picker.toggle(p.gus.id)
        picker.toggle(p.hana.id)
        #expect(picker.tray.map(\.id) == [p.hana.id, p.gus.id, p.ana.id])
    }

    @Test func suggestedIsTheFirstEightNotOnTheEventThenEveryoneElseAToZ() {
        var picker = picker()
        picker.suggestedIds = [p.ben.id, p.ana.id, p.chloe.id, p.diego.id, p.elif.id, p.farah.id, p.gus.id, p.hana.id, p.isaac.id, p.jules.id]
        let order = picker.order
        #expect(order.suggested == [p.ana.id, p.diego.id, p.elif.id, p.farah.id, p.gus.id, p.hana.id, p.isaac.id, p.jules.id])
        // Ben and Chloe are on the event: in everyone, greyed.
        #expect(order.everyone == [p.ben.id, p.chloe.id, p.ines.id, p.theo.id])
    }

    @Test func searchingANameIgnoresAccentsAndCase() {
        var picker = picker()
        picker.suggestedIds = [p.ines.id]
        picker.query = "INES"
        #expect(picker.order.suggested.isEmpty && picker.order.everyone == [p.ines.id])
        picker.query = "e"
        #expect(picker.order.everyone.first == p.ines.id)  // suggested first
        picker.query = "@ines"
        #expect(picker.order.everyone.isEmpty)  // that's a lookup
    }

    @Test(arguments: [
        ("(415) 555-0188", LookupKind.phone), ("+44 20 7946 0958", .phone), ("@rosa.e", .instagram),
    ])
    func lookupsAreWholeNumbersAndUsernames(text: String, kind: LookupKind) {
        #expect(LookupKind(text) == kind)
    }

    @Test(arguments: ["Rosa", "555-0188", "@", "@has space", "12345678901234567"])
    func namesAndPartsAreNotLookedUp(text: String) {
        #expect(LookupKind(text) == nil)
    }

    @Test func aPastEventNarrowsTheListToItsPeopleAToZAndTicksNobody() {
        var picker = picker()
        picker.suggestedIds = [p.ana.id, p.gus.id]
        picker.from = .init(eventId: "E", title: "Beach bonfire", ids: [p.theo.id, p.ben.id, p.ana.id, p.hana.id], isHidden: false)
        // No Suggested; Ben's on this event, so he's there greyed.
        #expect(picker.order.suggested.isEmpty && picker.order.everyone == [p.ana.id, p.ben.id, p.hana.id, p.theo.id])
        #expect(picker.selected.isEmpty)
        // Typing searches within it.
        picker.query = "na"
        #expect(picker.order.everyone == [p.ana.id, p.hana.id])
        picker.query = ""
        picker.from = nil
        #expect(picker.order.suggested == [p.ana.id, p.gus.id] && picker.order.everyone.count == 10)
    }

    @Test func aHiddenGuestListShowsNobody() {
        var picker = picker()
        picker.from = .init(eventId: "E", title: "Beach bonfire", ids: [p.ana.id], isHidden: true)
        #expect(picker.order.suggested.isEmpty && picker.order.everyone.isEmpty)
    }

    @Test func thePastEventsWords() {
        func from(_ ids: [Person.ID], hidden: Bool = false) -> InvitePicker.PastFilter {
            .init(eventId: "E", title: "Beach bonfire", ids: ids, isHidden: hidden)
        }
        #expect(InvitePicker.showing(from([p.ana.id, p.ben.id, p.gus.id, p.hana.id])) == "Showing 4 from Beach bonfire.")
        #expect(InvitePicker.showing(from([p.ana.id])) == "Showing 1 from Beach bonfire.")
        #expect(InvitePicker.showing(from([])) == "No one else from Beach bonfire.")
        #expect(InvitePicker.showing(from([p.ana.id], hidden: true)) == "Beach bonfire's guest list isn't shown to you.")
    }

    @Test func detailsUseTheWebsWords() {
        let friend = Friend(person: p.ana, source: .invite, eventsInCommon: 3, lastTogetherAt: nil)
        #expect(InvitePicker.detail(for: friend) == "Invitation, 3 events together")
        #expect(InvitePicker.detail(for: Friend(person: p.ana, source: .sharedEvents, eventsInCommon: 1, lastTogetherAt: nil)) == "1 event together")
        // A friend link is an icon, not words.
        #expect(InvitePicker.detail(for: Friend(person: p.ana, source: .link, eventsInCommon: 2, lastTogetherAt: nil)) == "2 events together")
        #expect(InvitePicker.detail(for: Friend(person: p.ana, source: .link, eventsInCommon: 0, lastTogetherAt: nil)).isEmpty)
        #expect(InvitePicker.invitedNotice(7) == "Invited 7 people." && InvitePicker.invitedNotice(1) == "Invited 1 person.")
    }

    @MainActor @Test func filteringByAPastEventLoadsItsPeopleAndTicksNobody() async throws {
        let session = AppSession.mock(delay: .zero)
        try await session.signInWithPasskey()
        let repository = session.repository
        let model = InviteModel(event: try await repository.event(id: MockEvents.gameNightId), me: MockPeople.maya.id)
        await model.load(from: repository)
        let bonfire = try await repository.event(id: MockEvents.bonfireId)
        let going = try await repository.guestList(eventId: bonfire.id, status: .going, page: PageRequest(limit: 100))
        let maybe = try await repository.guestList(eventId: bonfire.id, status: .maybe, page: PageRequest(limit: 100))
        let expected = Set(bonfire.hosts.map(\.person.id) + (going.guests + maybe.guests).map(\.person.id)).subtracting([MockPeople.maya.id])
        #expect(!expected.isEmpty)
        let words = await model.filter(by: bonfire.id, using: repository)
        #expect(words == "Showing \(expected.count) from Beach bonfire.")
        #expect(model.fromId == bonfire.id && Set(model.picker.order.everyone) == expected)
        #expect(model.picker.selected.isEmpty)
        // "Everyone" clears it.
        #expect(await model.filter(by: nil, using: repository) == nil)
        #expect(model.fromId == nil && model.picker.from == nil)
    }
}
