import Foundation
import Testing
import UserNotifications
@testable import CanopyEvents

/// Notifications with buttons: the categories registered at launch, the
/// payload a push carries, the words, and what the buttons and a tap do
/// (through the responder, against the mock).
@MainActor
struct NotificationTests {
    @Test func theInviteCategoryHasGoingAndCantGoBehindUnlock() throws {
        let category = try #require(NotificationCategory.all.first { $0.identifier == "EVENT_INVITE" })
        #expect(category.actions.map(\.identifier) == ["GOING", "NOT_GOING"])
        #expect(category.actions.map(\.title) == ["Going", "Can't Go"])
        #expect(category.actions.allSatisfy { $0.options.contains(.authenticationRequired) })
        #expect(category.actions.allSatisfy { !$0.options.contains(.foreground) && !$0.options.contains(.destructive) })
        #expect(category.actions.map { $0.icon != nil } == [true, true])
        #expect(NotificationCategory(type: .invited) == .eventInvite)
        #expect(NotificationCategory(type: .rsvp) == nil)
    }

    @Test func actionsAnswer() {
        #expect(NotificationAction(rawValue: "GOING")?.rsvpStatus == .going)
        #expect(NotificationAction(rawValue: "NOT_GOING")?.rsvpStatus == .notGoing)
        #expect(NotificationAction(rawValue: UNNotificationDefaultActionIdentifier) == nil)
    }

    @Test func payloadsRoundTripAndNeedAnEvent() throws {
        let payload = try #require(NotificationPayload(MockNotifications.adamInvite))
        #expect(payload.type == .invited && payload.eventId == MockEvents.eggsId && payload.actorName == "Adam Smith")
        #expect(NotificationPayload(userInfo: payload.userInfo) == payload)
        // As APNs delivers it: aps beside our keys, an id as a number, a type from the future.
        let push: [AnyHashable: Any] = ["aps": ["category": "EVENT_INVITE"], "type": "poll", "eventId": "4fQ9xKpL2mZa",
                                        "notificationId": 17]
        let parsed = try #require(NotificationPayload(userInfo: push))
        #expect(parsed.type == .unknown && parsed.notificationId == "17")
        #expect(NotificationPayload(userInfo: ["type": "invited"]) == nil)
    }

    @Test func theTestNotificationReadsAsAsked() throws {
        let invite = MockNotifications.adamInvite
        #expect(NotificationWording.title(for: invite) == "Adam Smith")
        let body = try #require(NotificationWording.body(for: invite))
        #expect(body.hasPrefix("10/16") && body.hasSuffix(" · 7p · Throw Eggs at Karl"))
        if Calendar.current.component(.month, from: .now) < 10
            || (Calendar.current.component(.month, from: .now) == 10 && Calendar.current.component(.day, from: .now) <= 16) {
            #expect(body == "10/16 · 7p · Throw Eggs at Karl")
        }
    }

    @Test func goingFromTheNotificationMovesTheInvite() async throws {
        let session = AppSession.mock(delay: .zero)
        try await session.signInWithPasskey()
        let responder = NotificationResponder(session: session)
        let payload = try #require(NotificationPayload(MockNotifications.adamInvite))
        let before = session.dataVersion
        await responder.respond(to: "GOING", payload: payload)
        #expect(try await !session.repository.allEvents(.invitations).contains { $0.id == MockEvents.eggsId })
        #expect(try await session.repository.allEvents(.upcoming).contains { $0.id == MockEvents.eggsId })
        #expect(session.dataVersion == before + 1)
        await responder.respond(to: "NOT_GOING", payload: payload)
        #expect(try await session.repository.allEvents(.declined).contains { $0.id == MockEvents.eggsId })
        #expect(responder.opening == nil)
    }

    @Test func aTapOpensTheEventOnItsTab() async throws {
        let session = AppSession.mock(delay: .zero)
        let responder = NotificationResponder(session: session)
        let payload = try #require(NotificationPayload(MockNotifications.adamInvite))
        await responder.respond(to: UNNotificationDefaultActionIdentifier, payload: payload)
        #expect(responder.opening == OpenedEvent(payload))
        #expect(responder.opening?.tab == .invites)
        // Signed out, a button does nothing.
        await responder.respond(to: "GOING", payload: payload)
        #expect(session.dataVersion == 0)
    }

    @Test(arguments: [
        ((2026, 10, 16, 19, 0), "10/16 · 7p"), ((2026, 10, 16, 19, 30), "10/16 · 7:30p"),
        ((2026, 10, 16, 12, 0), "10/16 · 12p"), ((2026, 10, 17, 0, 0), "10/17 · 12a"),
        ((2026, 1, 2, 9, 5), "1/2 · 9:05a"), ((2027, 1, 2, 0, 15), "1/2/27 · 12:15a"),
    ])
    func theWhenIsCompact(at: (Int, Int, Int, Int, Int), words: String) throws {
        let zone = try #require(TimeZone(identifier: "America/New_York"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let date = try #require(calendar.date(from: DateComponents(year: at.0, month: at.1, day: at.2, hour: at.3, minute: at.4)))
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 8)))
        #expect(NotificationWhen.string(date, in: zone, now: now) == words)
    }

    @Test func theWhenIsOnTheEventsClock() throws {
        // 7 PM in New York is 4 PM in Los Angeles: the event's own clock wins.
        let ny = try #require(TimeZone(identifier: "America/New_York"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = ny
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 16, hour: 19)))
        #expect(NotificationWhen.string(date, in: ny, now: date) == "10/16 · 7p")
        #expect(NotificationWhen.string(date, in: try #require(TimeZone(identifier: "America/Los_Angeles")), now: date) == "10/16 · 4p")
    }
}
