import Foundation
import Testing
@testable import CanopyEvents

/// The guests sheet (`GuestTabs`, `GuestsModel`): a tab per status there's
/// anyone in, in the web's order, Invited and Removed for hosts only, the
/// counts and plus-ones, searching every tab, and a host's Remove and Undo
/// against the mock.
@MainActor
struct GuestTabsTests {
    private let p = MockPeople.self

    private func guest(_ person: Person, _ status: RSVPStatus, plus: Int = 0) -> Guest {
        Guest(person: person, status: status, guests: plus, guestsOverLimit: false, respondedAt: nil)
    }

    private func tabs(isHost: Bool) -> GuestTabs {
        let guests = [guest(p.ana, .going, plus: 2), guest(p.ben, .waitlisted), guest(p.ines, .maybe),
                      guest(p.chloe, .notGoing), guest(p.diego, .going)] + (isHost ? [guest(p.elif, .invited)] : [])
        var counts = RSVPCounts(going: 2, maybe: 1, notGoing: 1, invited: isHost ? 1 : nil, waitlisted: 1)
        counts.guests.going = 2
        return GuestTabs(guests: guests, removed: isHost ? [guest(p.gus, .removed)] : [], counts: counts, isHost: isHost)
    }

    @Test func tabsAreInTheWebsOrderAndHostsAloneSeeInvitedAndRemoved() {
        #expect(tabs(isHost: true).tabs == [.going, .maybe, .invited, .notGoing, .waitlisted, .removed])
        #expect(tabs(isHost: false).tabs == [.going, .maybe, .notGoing, .waitlisted])
        // Nobody in a status: no tab.
        var none = tabs(isHost: false)
        none.guests.removeAll { $0.status == .maybe }
        none.counts.maybe = 0
        #expect(!none.tabs.contains(.maybe))
    }

    @Test func countsPlusOnesAndTheChosenTab() {
        let host = tabs(isHost: true)
        #expect(host.summary(.going) == "2 Going · +2 guests")
        #expect(host.summary(.waitlisted) == "1 Waitlist" && host.summary(.notGoing) == "1 Can't Go")
        #expect(host.count(.removed) == 1 && host.rows(in: .removed).map(\.id) == [p.gus.id])
        #expect(host.shown(nil) == .going && host.shown(.maybe) == .maybe)
        // A guest can't land on a host's tab.
        #expect(tabs(isHost: false).shown(.removed) == .going)
    }

    @Test func searchCoversEveryTabAccentsAside() {
        var host = tabs(isHost: true)
        host.query = "INES"
        #expect(host.isSearching && host.matches.map(\.id) == [p.ines.id])
        host.query = "us"
        #expect(host.matches.map(\.id) == [p.gus.id])  // the removed too, for hosts
        var guest = tabs(isHost: false)
        guest.query = "us"
        #expect(guest.matches.isEmpty)
    }

    @Test func aHostRemovesAndUndoes() async throws {
        let repository = MockEventsRepository(backend: MockBackend(delay: .zero), personId: p.maya.id)
        let model = GuestsModel(event: try await repository.event(id: MockEvents.gameNightId))
        await model.load(from: repository)
        #expect(model.isHost && model.guestsVisible == true)
        #expect(model.tabs?.tabs == [.going, .waitlisted])
        let ben = try #require(model.tabs?.rows(in: .going).first { $0.id == p.ben.id })

        #expect(await model.remove(ben, using: repository))
        #expect(model.notice == "Removed \(p.ben.fullName).")
        // His seat went to the first on the waitlist.
        #expect(model.tabs?.tabs == [.going, .waitlisted, .removed] && model.tabs?.count(.waitlisted) == 1)
        #expect(model.tabs?.rows(in: .removed).map(\.id) == [p.ben.id])

        #expect(await model.restore(ben, using: repository))
        #expect(model.notice == "\(p.ben.fullName) is invited again.")
        #expect(model.tabs?.tabs == [.going, .invited, .waitlisted])
    }

    @Test func guestsSeeWhatTheGuestListGivesThem() async throws {
        let repository = MockEventsRepository(backend: MockBackend(delay: .zero), personId: p.maya.id)
        let rooftop = GuestsModel(event: try await repository.event(id: MockEvents.rooftopId))
        await rooftop.load(from: repository)
        #expect(!rooftop.isHost && rooftop.tabs?.removed.isEmpty == true)
        #expect(rooftop.tabs?.tabs.contains(.invited) == false && rooftop.tabs?.tabs.isEmpty == false)
        // Invited to a list shown only to people who've answered: nothing.
        let hike = GuestsModel(event: try await repository.event(id: MockEvents.hikeId))
        await hike.load(from: repository)
        #expect(hike.guestsVisible == false && hike.tabs?.guests.isEmpty == true)
    }
}
