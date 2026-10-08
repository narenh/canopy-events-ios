import Foundation
import Testing
@testable import CanopyEvents

/// The invite sheet's picking and order (`InvitePicker`), the web's
/// `inviteOrder`, `listPickable` and "Invite all <n>".
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

    @Test func detailsUseTheWebsWords() {
        let friend = Friend(person: p.ana, source: .invite, eventsInCommon: 3, lastTogetherAt: nil)
        #expect(InvitePicker.detail(for: friend) == "Invitation · 3 events together")
        #expect(InvitePicker.detail(for: Friend(person: p.ana, source: .sharedEvents, eventsInCommon: 1, lastTogetherAt: nil)) == "1 event together")
        #expect(InvitePicker.invitedNotice(7) == "Invited 7 people." && InvitePicker.invitedNotice(1) == "Invited 1 person.")
    }
}
