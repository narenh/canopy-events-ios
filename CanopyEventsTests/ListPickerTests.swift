import Foundation
import Testing
@testable import CanopyEvents

/// The picker for a list's "Add people" and the invite sheet's "Save as
/// list": everyone on the list greyed "On list", the words that change
/// with the kind, what adding and saving say, and both driven against
/// the mock as Maya.
@MainActor
struct ListPickerTests {
    private let p = MockPeople.self

    private func signedIn() async throws -> any EventsRepository {
        let session = AppSession.mock(delay: .zero)
        try await session.signInWithPasskey()
        return session.repository
    }

    @Test func onListIsTakenAndCantBePicked() {
        var picker = PeoplePicker()
        picker.kind = .list
        picker.me = p.maya.id
        for person in [p.ana, p.ben, p.theo] { picker.add(person, detail: "") }
        picker.taken = [p.ana.id: .onList]
        picker.lists = [.init(id: "L", name: "Drag Race", memberIds: [p.ana.id, p.ben.id])]
        picker.setPicked([p.ana.id, p.ben.id, p.maya.id], true)
        #expect(picker.selected == [p.ben.id] && picker.pickable(in: picker.lists[0]) == [p.ben.id])
        // Still listed, greyed, A to Z with everyone else.
        #expect(picker.order.everyone == [p.ana.id, p.ben.id, p.theo.id])
    }

    @Test func theWordsFollowTheKind() {
        #expect(PeoplePicker.Kind.invite.send(0) == "Invite" && PeoplePicker.Kind.invite.send(7) == "Invite 7")
        #expect(PeoplePicker.Kind.list.send(0) == "Add" && PeoplePicker.Kind.list.send(5) == "Add 5")
        #expect(PeoplePicker.Kind.invite.all(3) == "Invite all 3" && PeoplePicker.Kind.list.all(3) == "Add all 3")
        #expect(PeoplePicker.Kind.invite.allDone == "All invited" && PeoplePicker.Kind.list.allDone == "All on it")
    }

    @Test func whatAddingAndSavingSay() {
        #expect(PeoplePicker.addedNotice(added: 5, invitedTo: 1) == "Added 5 people. Invited them to 1 event.")
        #expect(PeoplePicker.addedNotice(added: 1, invitedTo: 0) == "Added 1 person.")
        #expect(PeoplePicker.addedNotice(added: 0, invitedTo: 0) == "Everyone you picked is on it already.")
        #expect(PeoplePicker.addedNotice(added: 2, invitedTo: 3) == "Added 2 people. Invited them to 3 events.")
        #expect(PeoplePicker.savedNotice(5, to: "Regulars", invitedTo: 0) == "Saved 5 people to Regulars.")
        #expect(PeoplePicker.savedNotice(1, to: "Drag Race", invitedTo: 1) == "Saved 1 person to Drag Race. Invited them to 1 event.")
    }

    @Test func joinedOrAdded() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 8))!
        let now = Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 1))!
        #expect(JoinedDate.string(for: date, source: .link, now: now) == "Joined Oct 8")
        #expect(JoinedDate.string(for: date, source: .added, now: now) == "Added Oct 8")
    }

    @Test func addPeopleGreysTheListAndLeavesItOutOfYourLists() async throws {
        let repository = try await signedIn()
        let dragRace = try #require(try await repository.lists().first { $0.id == MockLists.dragRaceId })
        let model = PeoplePickerModel(target: .list(dragRace), me: p.maya.id)
        await model.load(from: repository)
        #expect(model.hasLoaded && model.picker.kind == .list)
        #expect(model.picker.lists.map(\.name) == ["Climbing"])
        #expect(model.picker.taken.count == 20 && model.picker.taken[p.theo.id] == .onList)
        #expect(model.picker.people[p.zane.id] != nil)  // on it, so listed, greyed
        // Climbing's five, none on Drag Race: "Add all 5".
        #expect(model.picker.pickable(in: model.picker.lists[0]).count == 5)

        model.picker.toggleAll(in: model.picker.lists[0])
        let words = await model.addToList(using: repository)
        // On the finale, so they're invited to it.
        #expect(words == "Added 5 people. Invited them to 1 event.")
        #expect(model.picker.selected.isEmpty && model.picker.taken[p.ana.id] == .onList)
        #expect(try await repository.lists().first { $0.id == MockLists.dragRaceId }?.memberCount == 25)
    }

    @Test func saveAsListInvitesNobodyHereButTheListsEventsDo() async throws {
        let repository = try await signedIn()
        let gameNight = try await repository.event(id: MockEvents.gameNightId)
        let model = PeoplePickerModel(target: .event(gameNight), me: p.maya.id)
        await model.load(from: repository)
        let picks = [p.theo.id, p.ines.id].filter(model.picker.isPickable)
        #expect(picks.count == 2)
        model.picker.setPicked(picks, true)

        #expect(await model.saveAsList(to: nil, named: "Regulars", using: repository))
        #expect(model.notice == "Saved 2 people to Regulars.")
        let regulars = try #require(model.picker.lists.first { $0.name == "Regulars" })
        #expect(regulars.memberIds == picks && model.picker.selected == picks)  // the picks stay
        #expect(try await repository.wholeGuestList(eventId: gameNight.id).guests.allSatisfy { !picks.contains($0.id) })

        // Sam isn't on Drag Race (on the finale): saving him there invites him to it, not here.
        model.picker.add(p.sam.person, detail: "")
        model.picker.setPicked([p.sam.id], true)
        #expect(await model.saveAsList(to: MockLists.dragRaceId, named: "", using: repository))
        #expect(model.notice == "Saved 3 people to Drag Race. Invited them to 1 event.")
        #expect(try await repository.wholeGuestList(eventId: MockEvents.dragFinaleId).guests.contains { $0.id == p.sam.id })
        #expect(model.picker.isPickable(p.sam.id))
    }
}
