import Foundation
import Testing
@testable import CanopyEvents

/// The spec's own examples (`APISamples`) decode into the models, and
/// survive a round trip through the API's encoder. Not in a target yet,
/// like `MockFlowTests` (see ARCHITECTURE.md, "Tests").
struct APIDecodingTests {
    private func decode<T: Codable & Equatable & Sendable>(_ type: T.Type, _ json: String) throws -> T {
        let value = try JSONDecoder.eventsAPI.decode(T.self, from: Data(json.utf8))
        let again = try JSONDecoder.eventsAPI.decode(T.self, from: JSONEncoder.eventsAPI.encode(value))
        #expect(again == value, "\(T.self) changed in a round trip")
        return value
    }

    @Test func event() throws {
        let event = try decode(Event.self, APISamples.event)
        #expect(event.guestsAllowed == 1 && event.capacity == 20 && event.spotsLeft == 14)
        #expect(event.counts.total.going == 6 && event.counts.guests.going == 2)
        #expect(event.viewer?.rsvp?.guestsOverLimit == false && event.viewer?.canPost == true)
        #expect(event.viewer?.role == nil && event.hosts.first?.role == .creator)
        #expect(event.friendsGoing?.people.first?.shortName == "Ben O")
        #expect(event.startsAt == Date(timeIntervalSince1970: 1_793_500_200))
        #expect(event.coverImages.count == 4 && event.coverImages.last?.url == event.coverImageUrl)
        #expect(event.theme == .canopyGreen && event.coverTheme == .hue(24))
    }

    @Test func rsvpResult() throws {
        let result = try decode(RSVPResult.self, APISamples.rsvpResult)
        #expect(!result.waitlisted && result.event.myStatus == .going)
    }

    @Test func me() throws {
        let me = try decode(MeEnvelope.self, APISamples.meEnvelope)
        #expect(!me.person.emailVerified && !me.hasHosted && me.verifyUrl != nil)
    }

    @Test func guestList() throws {
        let list = try decode(GuestList.self, APISamples.guestList)
        #expect(list.guests.first?.status == .going && list.nextCursor == nil)
        #expect(list.counts.invited == nil)
    }

    @Test func wallKeepsUnknownTypesOut() throws {
        let wall = try decode(Wall.self, APISamples.wall)
        #expect(wall.entries.map(\.type) == [.post, .timeChanged, .unknown])
        #expect(wall.entries[1].details?.endsAt == nil && wall.entries[1].details?.timeZone == "America/Los_Angeles")
        #expect(wall.entries.filter(\.isKnown).count == 2 && wall.nextCursor == "WzMsIjA")
        #expect(WallEntryText.string(for: wall.entries[2]) == nil)
    }

    @Test func notifications() throws {
        let list = try decode(NotificationList.self, APISamples.notifications)
        let item = try #require(list.notifications.first)
        #expect(item.type == .rsvp && item.count == 4 && item.details?.status == .going)
        #expect(item.event?.id == "4fQ9xKpL2mZa" && list.unreadCount == 1)
        #expect(item.event?.themeHue == 300 && item.event?.coverImages == [])
    }

    @Test func inviteResult() throws {
        let result = try decode(InviteResult.self, APISamples.inviteResult)
        #expect(result.skipped.map(\.reason) == [.notFound, .removed])
    }

    @Test func errors() throws {
        let error = try decode(APIError.self, APISamples.signInRequired)
        #expect(error.reason == .signInRequired && error.signIn != nil && error.quickSignUp != nil)
        #expect(error.message == "sign in first")
    }

    @Test func accountService() throws {
        let state = try decode(EmailState.self, APISamples.emailState)
        #expect(state.state == .existing && state.unverified == false)
        let me = try decode(Me.self, APISamples.accountPerson)
        #expect(me.findable == true && me.photoUrl != nil)
    }
}
