import Foundation

extension MockEvents {
    static let rooftopId = "4fQ9xKpL2mZa"
    static let birthdayId = "Bd7Picnic26x"
    static let gameNightId = "Gm8Night4Fun"
    static let hikeId = "Hk3Sunrise9q"
    static let supperClubId = "Sp5OaxacaClb"
    static let galleryId = "Gl2Opening7n"
    static let karaokeId = "Kr6Jules30th"
    static let potteryId = "Pt4Workshop1"
    static let triviaId = "Tr2Trivia77k"

    static var upcoming: [MockEventRecord] {
        let p = MockPeople.self
        let maya = p.maya.person, sam = p.sam.person
        return [
            MockEventRecord(
                event: event(id: rooftopId, title: "Rooftop dinner", description: "Pasta, a view, and too much wine. Bring a jacket: it gets windy up there.",
                             days: 3, hour: 19, minute: 30, hours: 4, locationName: "Ana's place",
                             locationAddress: "1 Market St, San Francisco", hosts: [host(p.ana)], guestsAllowed: 1, cover: "rooftop"),
                guests: [guest(maya, .going, plus: 1), guest(p.ben, .going, plus: 2), guest(p.chloe, .going), guest(p.gus, .maybe),
                         guest(p.hana, .notGoing), guest(sam, .invited), guest(p.lena, .going), guest(p.kofi, .invited)],
                invitedIds: [maya.id, sam.id, p.kofi.id, p.ben.id]),
            MockEventRecord(
                event: event(id: birthdayId, title: "Maya's birthday picnic", description: "Blankets, snacks, frisbee. Ben's bringing the speaker.",
                             days: 10, hour: 13, hours: 4, locationName: "Dolores Park",
                             locationAddress: "Dolores St & 19th St, San Francisco", hosts: [host(maya), cohost(p.ben)], guestsAllowed: 2, cover: "picnic"),
                guests: [guest(p.ana, .going, plus: 1), guest(p.chloe, .going), guest(p.diego, .maybe), guest(p.elif, .going),
                         guest(p.farah, .invited), guest(p.gus, .invited), guest(p.hana, .going, plus: 2), guest(p.isaac, .notGoing), guest(p.jules, .going)],
                invitedIds: [p.farah.id, p.gus.id]),
            MockEventRecord(
                event: event(id: gameNightId, title: "Board game night", description: "Six seats at the table. Wingspan, then whatever we can still focus on.",
                             days: 5, hour: 19, hours: 4, locationName: "Maya's apartment",
                             locationAddress: "742 Valencia St, Apt 3, San Francisco", visibility: .responded, hosts: [host(maya)], capacity: 6, guestsAllowed: 1),
                guests: [guest(p.ben, .going), guest(p.diego, .going, plus: 1), guest(p.kofi, .going), guest(p.lena, .going),
                         guest(p.isaac, .going), guest(p.gus, .waitlisted), guest(p.farah, .waitlisted)]),
            MockEventRecord(
                event: event(id: hikeId, title: "Sunrise hike at Mt Tam", description: "Meet at the lot. Headlamps, layers, coffee after.",
                             days: 7, hour: 6, hours: 4, locationName: "Pantoll Ranger Station",
                             locationAddress: "801 Panoramic Hwy, Mill Valley", visibility: .responded, hosts: [host(p.chloe)], cover: "mountain"),
                guests: [guest(maya, .invited), guest(p.ana, .going), guest(p.diego, .going), guest(p.elif, .maybe), guest(p.jules, .invited)],
                invitedIds: [maya.id, p.jules.id]),
            MockEventRecord(
                event: event(id: supperClubId, title: "Supper club: Oaxaca", description: "Seven courses, mole three ways. Strictly eight seats.",
                             days: 12, hour: 19, hours: 3, locationName: "Diego's kitchen",
                             locationAddress: "2100 Mission St, San Francisco", hosts: [host(p.diego)], capacity: 8, cover: "supper"),
                guests: [p.ana, p.ben, p.chloe, p.elif, p.farah, p.hana, p.isaac, p.kofi].map { guest($0, .going) }
                    + [guest(maya, .waitlisted), guest(p.gus, .waitlisted)]),
            MockEventRecord(
                event: event(id: galleryId, title: "Gallery opening: Elif Yilmaz", description: "New paintings. Wine and a short talk at 7.",
                             days: 20, hour: 18, hours: 3, timeZone: "America/New_York", locationName: "Kesting Gallery",
                             locationAddress: "541 W 25th St, New York", visibility: .responded, hosts: [host(p.elif)], cover: "gallery"),
                guests: [guest(maya, .maybe), guest(p.lena, .going), guest(p.isaac, .going)]),
            MockEventRecord(
                event: event(id: karaokeId, title: "Karaoke for Jules' 30th", days: 4, hour: 21, hours: 3, locationName: "The Mint",
                             locationAddress: "1942 Market St, San Francisco", hosts: [host(p.jules)], cancelled: true),
                guests: [guest(maya, .going), guest(p.ana, .going), guest(p.ben, .maybe), guest(p.hana, .going)]),
            MockEventRecord(
                event: event(id: potteryId, title: "Pottery workshop", description: "Wheel-throwing for beginners. Wear clothes you don't love.",
                             days: 14, hour: 11, hours: 3, locationName: "Clayroom",
                             locationAddress: "180 Capp St, San Francisco", hosts: [host(p.farah)], guestsAllowed: 1, cover: "pottery"),
                guests: [guest(maya, .invited), guest(sam, .going), guest(p.kofi, .going), guest(p.lena, .maybe)],
                invitedIds: [maya.id]),
            MockEventRecord(
                event: event(id: triviaId, title: "Pub trivia", description: "Team name pending. Last place buys the next round.",
                             days: 6, hour: 20, hours: 2, locationName: "The Edinburgh Castle",
                             locationAddress: "950 Geary St, San Francisco", hosts: [host(p.gus)]),
                guests: [guest(maya, .notGoing), guest(p.isaac, .going), guest(p.kofi, .going), guest(p.ben, .maybe)],
                invitedIds: [maya.id, p.isaac.id]),
        ]
    }
}
