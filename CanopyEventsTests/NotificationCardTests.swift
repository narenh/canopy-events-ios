import Foundation
import Testing
import UserNotifications
@testable import CanopyEvents

/// The expanded notification's card: what it's built from, and that it
/// survives the trip through a notification's userInfo.
@MainActor
struct NotificationCardTests {
    @Test func theCardRidesInUserInfo() throws {
        let card = NotificationCard(event: PreviewData.event(MockEvents.rooftopId),
                                    guests: PreviewData.guestList(MockEvents.rooftopId).guests)
        let value = try #require(card.userInfoValue)
        let userInfo: [AnyHashable: Any] = ["eventId": card.eventId, NotificationCard.userInfoKey: value]
        #expect(NotificationCard(userInfo: userInfo) == card)
        #expect(NotificationCard(userInfo: ["eventId": "x"]) == nil)
        // Small: it has to fit in a push (4 KB in all).
        #expect(try JSONSerialization.data(withJSONObject: value).count < 2_000)
    }

    @Test func theCardIsTheEventsAndFriendsComeFirst() throws {
        let event = PreviewData.event(MockEvents.rooftopId)
        let card = NotificationCard(event: event, guests: PreviewData.guestList(MockEvents.rooftopId).guests)
        #expect(card.title == "Rooftop dinner" && card.theme == .hue(225) && card.locationName == "Ana's place")
        #expect(card.going == event.counts.going && card.maybe == event.counts.maybe)
        #expect(card.coverUrl?.absoluteString.contains("/800/") == true)
        let friends = event.friendsGoing?.people.map(\.fullName) ?? []
        #expect(Array(card.faces.map(\.name).prefix(friends.count)) == friends)
        #expect(card.faces.count <= 6 && card.faces.first?.initials.count == 2)
    }

    @Test func anEventWithNoCoverHasNoCoverUrl() {
        let card = NotificationCard(event: PreviewData.event(MockEvents.eggsId), guests: [])
        #expect(card.coverUrl == nil && card.title == "Throw Eggs at Karl" && card.faces.isEmpty)
    }

    /// What the Debug button sends: the content `scheduleTestInvite` builds
    /// carries a card the extension can read (the TestFlight bug was the
    /// extension never running, not the card; this keeps the card honest).
    @Test func theTestInviteCarriesACardTheExtensionCanRead() async throws {
        let repository = MockEventsRepository(signedInAs: MockPeople.maya, delay: .zero)
        let card = try await NotificationCard.load(MockEvents.eggsId, from: repository)
        let content = try #require(await LocalNotifications.content(for: MockNotifications.adamInvite, card: card))
        #expect(content.categoryIdentifier == "EVENT_INVITE")
        #expect(content.body.hasSuffix(" · 7p · Throw Eggs at Karl"))
        guard case .success(let read) = NotificationCard.read(content.userInfo) else {
            Issue.record("the extension couldn't read the card: \(NotificationCard.read(content.userInfo))")
            return
        }
        #expect(read == card && read.title == "Throw Eggs at Karl")
    }

    @Test func aMissingCardSaysWhy() {
        guard case .failure(let problem) = NotificationCard.read(["eventId": "x", "type": "invited"]) else {
            Issue.record("read a card from nothing")
            return
        }
        #expect(problem.description == "no card in userInfo (keys: eventId, type)")
        guard case .failure(.undecodable) = NotificationCard.read(["card": ["title": 3]]) else {
            Issue.record("decoded a broken card")
            return
        }
    }
}
