import Foundation

extension MockEvents {
    /// Maya's, with her Drag Race list on it (which invites the rest of it).
    static let dragFinaleId = "Dr7FinaleSF9"
    /// Ana's, with her Dumpling crew on it; Maya isn't invited.
    static let dumplingTwoId = "Dm3Dumpling4"

    /// Upcoming events made for lists (the rooftop dinner has Ana's
    /// Dumpling crew too: `listsOnEvents`, added in `MockEvents.all`).
    static var withLists: [MockEventRecord] {
        let p = MockPeople.self
        let maya = p.maya.person
        return [
            MockEventRecord(
                event: event(id: dragFinaleId, title: "Drag Race: the finale", description: "Snacks, a big screen and strong opinions. Lip sync for your life.",
                             days: 8, hour: 19, hours: 3, locationName: "Maya's apartment",
                             locationAddress: "742 Valencia St, Apt 3, San Francisco", hosts: [host(maya)], theme: .hue(320)),
                guests: [guest(p.theo, .going), guest(p.ines, .going), guest(p.noor, .going), guest(p.oscar, .maybe)],
                attachedLists: [MockAttachedList(listId: MockLists.dragRaceId, attachedAt: MockDate.ago(minutes: 60 * 24 * 5))]),
            MockEventRecord(
                event: event(id: dumplingTwoId, title: "Dumpling night II", description: "Round two. Pleating lessons for the newcomers.",
                             days: 16, hour: 19, locationName: "Ana's place",
                             locationAddress: "1 Market St, San Francisco", hosts: [host(p.ana)], cover: cover("dumplings2", hue: 35), theme: .hue(35)),
                guests: [guest(p.ben, .going), guest(p.hana, .maybe)],
                attachedLists: [MockAttachedList(listId: MockLists.dumplingCrewId, attachedAt: MockDate.ago(minutes: 60 * 24 * 3))]),
        ]
    }

    /// Lists on the other seed events: Ana's Dumpling crew on her rooftop
    /// dinner, so Maya (going, not on it) is offered "Get invited next time".
    static let listsOnEvents: [Event.ID: [MockAttachedList]] = [
        rooftopId: [MockAttachedList(listId: MockLists.dumplingCrewId, attachedAt: MockDate.ago(minutes: 60 * 24 * 6))],
    ]
}
