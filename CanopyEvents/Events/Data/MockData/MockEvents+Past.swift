import Foundation

extension MockEvents {
    static let dumplingId = "Dm9Dumpling2"
    static let bonfireId = "Bf1Bonfire88"
    static let bookClubId = "Bk0BookClub5"
    static let snatchGameId = "Dr4SnatchGm1"
    static let rusicalId = "Dr2Rusical77"
    static let boulderingId = "Cl9Boulder05"

    /// Events that are over. Being at these together is what makes people friends.
    static var past: [MockEventRecord] {
        let p = MockPeople.self
        let maya = p.maya.person
        return [
            MockEventRecord(
                event: event(id: dumplingId, title: "Dumpling night", days: -9, hour: 19, locationName: "Ana's place",
                             locationAddress: "1 Market St, San Francisco", hosts: [host(p.ana)], cover: cover("dumplings", hue: 35), theme: .hue(35)),
                guests: [guest(maya, .going), guest(p.ben, .going), guest(p.chloe, .going), guest(p.kofi, .going), guest(p.hana, .maybe)]),
            MockEventRecord(
                event: event(id: bonfireId, title: "Beach bonfire", description: "Fire pit 6. S'mores provided.", days: -30, hour: 18, hours: 4,
                             locationName: "Ocean Beach", locationAddress: "Great Hwy, fire pit 6, San Francisco", hosts: [host(maya)], cover: cover("bonfire", hue: 20)),
                guests: [guest(p.ana, .going), guest(p.ben, .going), guest(p.diego, .going), guest(p.elif, .going),
                         guest(p.jules, .going), guest(p.gus, .notGoing)]),
            MockEventRecord(
                event: event(id: bookClubId, title: "Book club: The Overstory", days: -60, hour: 19, hours: 2,
                             locationName: "Lena's", locationAddress: "55 Hoff St, San Francisco", hosts: [host(p.lena)]),
                guests: [guest(maya, .going), guest(p.hana, .going), guest(p.isaac, .going)]),
            MockEventRecord(
                event: event(id: snatchGameId, title: "Drag Race: Snatch Game", days: -14, hour: 19, locationName: "Maya's apartment",
                             locationAddress: "742 Valencia St, Apt 3, San Francisco", hosts: [host(maya)], theme: .hue(320)),
                guests: [p.theo, p.ines, p.marcus, p.noor, p.oscar, p.quinn, p.sven, p.tomas, p.uma, p.vic, p.wren, p.xavier,
                         p.ben, p.jules, p.kofi].map { guest($0, .going) }
                    + [guest(p.yuki, .maybe), guest(p.zane, .maybe), guest(p.lena, .notGoing)]),
            MockEventRecord(
                event: event(id: rusicalId, title: "Drag Race: the Rusical", days: -42, hour: 19, locationName: "Maya's apartment",
                             locationAddress: "742 Valencia St, Apt 3, San Francisco", hosts: [host(maya)], theme: .hue(320)),
                guests: [p.theo, p.ines, p.noor, p.oscar, p.quinn, p.tomas, p.wren, p.amara, p.bea, p.jules].map { guest($0, .going) }
                    + [guest(p.marcus, .maybe)]),
            MockEventRecord(
                event: event(id: boulderingId, title: "Bouldering at Mission Cliffs", days: -21, hour: 18, hours: 2,
                             locationName: "Mission Cliffs", locationAddress: "2295 Harrison St, San Francisco", hosts: [host(p.diego)], theme: .hue(160)),
                guests: [maya, p.ana, p.cyrus, p.dani, p.emeka, p.freya, p.gio, p.hugo].map { guest($0, .going) }),
        ]
    }
}
