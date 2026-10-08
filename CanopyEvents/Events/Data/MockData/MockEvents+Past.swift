import Foundation

extension MockEvents {
    static let dumplingId = "Dm9Dumpling2"
    static let bonfireId = "Bf1Bonfire88"
    static let bookClubId = "Bk0BookClub5"

    /// Events that are over. Being at these together is what makes people friends.
    static var past: [MockEventRecord] {
        let p = MockPeople.self
        let maya = p.maya.person
        return [
            MockEventRecord(
                event: event(id: dumplingId, title: "Dumpling night", days: -9, hour: 19, locationName: "Ana's place",
                             locationAddress: "1 Market St, San Francisco", hosts: [host(p.ana)], cover: "dumplings"),
                guests: [guest(maya, .going), guest(p.ben, .going), guest(p.chloe, .going), guest(p.kofi, .going), guest(p.hana, .maybe)]),
            MockEventRecord(
                event: event(id: bonfireId, title: "Beach bonfire", description: "Fire pit 6. S'mores provided.", days: -30, hour: 18, hours: 4,
                             locationName: "Ocean Beach", locationAddress: "Great Hwy, fire pit 6, San Francisco", hosts: [host(maya)], cover: "bonfire"),
                guests: [guest(p.ana, .going), guest(p.ben, .going), guest(p.diego, .going), guest(p.elif, .going),
                         guest(p.jules, .going), guest(p.gus, .notGoing)]),
            MockEventRecord(
                event: event(id: bookClubId, title: "Book club: The Overstory", days: -60, hour: 19, hours: 2,
                             locationName: "Lena's", locationAddress: "55 Hoff St, San Francisco", hosts: [host(p.lena)]),
                guests: [guest(maya, .going), guest(p.hana, .going), guest(p.isaac, .going)]),
        ]
    }
}
