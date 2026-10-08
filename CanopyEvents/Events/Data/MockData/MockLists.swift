import Foundation

/// The mock world's lists. Maya has "Drag Race" (20 people, on her
/// finale viewing) and "Climbing"; Ana has "Dumpling crew" (on her
/// rooftop dinner, which Maya is going to, and on her next dumpling
/// night, which Maya isn't invited to), so joining it from the rooftop
/// page invites Maya to one event; Maya is on Lena's "Supper club".
enum MockLists {
    static let dragRaceId = "LqDragRace01"
    static let climbingId = "LqClimbing02"
    static let dumplingCrewId = "LqDumpling03"
    static let supperClubId = "LqSupper0004"
    /// Ana's list's link code: what Profile's Debug section opens.
    static let dumplingCrewCode = "Dm8CrewJoin4"

    static var all: [MockListRecord] {
        let p = MockPeople.self
        return [
            list(dragRaceId, owner: p.maya.person, "Drag Race", code: "9xQ2mPc7LtRe", madeDaysAgo: 70, members: [
                p.theo, p.ines, p.noor, p.oscar, p.quinn, p.tomas, p.wren, p.amara, p.bea, p.jules,
                p.marcus, p.sven, p.uma, p.vic, p.xavier, p.ben, p.kofi, p.yuki, p.zane, p.chloe,
            ]),
            list(climbingId, owner: p.maya.person, "Climbing", code: "Cl7mB3rsJoin", madeDaysAgo: 30, members: [
                p.ana, p.diego, p.cyrus, p.dani, p.freya,
            ]),
            list(dumplingCrewId, owner: p.ana, "Dumpling crew", code: dumplingCrewCode, madeDaysAgo: 40, members: [
                p.ben, p.chloe, p.kofi, p.hana, p.emeka,
            ]),
            list(supperClubId, owner: p.lena, "Supper club", code: "Sp9ClubJoin2", madeDaysAgo: 50, members: [
                p.isaac, p.hana, p.maya.person,
            ]),
        ]
    }

    /// Zane is on Drag Race but opted out of Maya's invitations: putting
    /// the list on an event skips him without a word.
    static var optouts: [Person.ID: [Person.ID]] {
        [MockPeople.zane.id: [MockPeople.maya.id]]
    }

    /// Made `madeDaysAgo` days ago; the people joined in the order given,
    /// a day or two apart, the last one most recently.
    private static func list(_ id: String, owner: Person, _ name: String, code: String, madeDaysAgo: Int, members: [Person]) -> MockListRecord {
        let made = MockDate.ago(minutes: madeDaysAgo * 24 * 60)
        let step = TimeInterval(madeDaysAgo * 24 * 60 * 60) / Double(members.count + 1)
        return MockListRecord(
            id: id, ownerId: owner.id, name: name, code: code, createdAt: made,
            members: members.enumerated().map { ListMember(person: $1, joinedAt: made.addingTimeInterval(step * Double($0 + 1))) }
        )
    }
}
