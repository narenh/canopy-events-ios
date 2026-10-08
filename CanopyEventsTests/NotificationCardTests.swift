import Foundation
import Testing
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
}
