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
        #expect(category.actions.allSatisfy { !$0.options.contains(.foreground) })
        #expect(NotificationCategory(type: .invited) == .eventInvite)
        #expect(NotificationCategory(type: .rsvp) == nil)
    }

    @Test func actionsAnswer() {
        #expect(NotificationAction(rawValue: "GOING")?.rsvpStatus == .going)
        #expect(NotificationAction(rawValue: "NOT_GOING")?.rsvpStatus == .notGoing)
        #expect(NotificationAction(rawValue: UNNotificationDefaultActionIdentifier) == nil)
    }

    @Test func payloadsRoundTripAndNeedAnEvent() throws {
        let payload = try #require(NotificationPayload(MockNotifications.karlInvite))
        #expect(payload.type == .invited && payload.eventId == MockEvents.marxismId && payload.actorName == "Karl Marx")
        #expect(NotificationPayload(userInfo: payload.userInfo) == payload)
        // As APNs delivers it: aps beside our keys, an id as a number, a type from the future.
        let push: [AnyHashable: Any] = ["aps": ["category": "EVENT_INVITE"], "type": "poll", "eventId": "4fQ9xKpL2mZa",
                                        "notificationId": 17]
        let parsed = try #require(NotificationPayload(userInfo: push))
        #expect(parsed.type == .unknown && parsed.notificationId == "17")
        #expect(NotificationPayload(userInfo: ["type": "invited"]) == nil)
    }

    @Test func theTestNotificationReadsAsAsked() {
        let invite = MockNotifications.karlInvite
        #expect(NotificationWording.title(for: invite) == "Karl Marx")
        #expect(NotificationWording.body(for: invite) == "Invited you to Marxism 101")
    }

    @Test func goingFromTheNotificationMovesTheInvite() async throws {
        let session = AppSession.mock(delay: .zero)
        try await session.signInWithPasskey()
        let responder = NotificationResponder(session: session)
        let payload = try #require(NotificationPayload(MockNotifications.karlInvite))
        let before = session.dataVersion
        await responder.respond(to: "GOING", payload: payload)
        #expect(try await !session.repository.allEvents(.invitations).contains { $0.id == MockEvents.marxismId })
        #expect(try await session.repository.allEvents(.upcoming).contains { $0.id == MockEvents.marxismId })
        #expect(session.dataVersion == before + 1)
        await responder.respond(to: "NOT_GOING", payload: payload)
        #expect(try await session.repository.allEvents(.declined).contains { $0.id == MockEvents.marxismId })
        #expect(responder.opening == nil)
    }

    @Test func aTapOpensTheEventOnItsTab() async throws {
        let session = AppSession.mock(delay: .zero)
        let responder = NotificationResponder(session: session)
        let payload = try #require(NotificationPayload(MockNotifications.karlInvite))
        await responder.respond(to: UNNotificationDefaultActionIdentifier, payload: payload)
        #expect(responder.opening == OpenedEvent(payload))
        #expect(responder.opening?.tab == .invites)
        // Signed out, a button does nothing.
        await responder.respond(to: "GOING", payload: payload)
        #expect(session.dataVersion == 0)
    }
}
