import Foundation

/// Everything the app asks of the Canopy Events API, one method per
/// endpoint in its openapi.yaml. Screens only ever talk to this protocol,
/// through `@Environment(\.eventsRepository)`.
///
/// Answers that are one thing in an envelope (`{"event": …}`) come back
/// unwrapped; pages come back whole, with `nextCursor`. Methods throw
/// `APIError`. Today the only implementation is `MockEventsRepository`
/// (in-memory); a real `APIEventsRepository` slots in later.
protocol EventsRepository: AnyObject, Sendable {
    // MARK: You

    /// `GET /api/v1/me`
    func me() async throws -> MeEnvelope
    /// `GET /api/v1/me/friends`
    func friends(page: PageRequest) async throws -> FriendList

    // MARK: Notifications

    /// `GET /api/v1/me/notifications`, newest first, with the unread count.
    func notifications(page: PageRequest) async throws -> NotificationList
    /// `GET /api/v1/me/notifications/unread`: just the count, for a badge.
    func unreadNotificationCount() async throws -> Int
    /// `POST /api/v1/me/notifications/read` with 1 to 100 ids. Answers the unread count after.
    func markNotificationsRead(ids: [InboxNotification.ID]) async throws -> Int
    /// `POST /api/v1/me/notifications/read-all`. Answers the unread count after (0).
    func markAllNotificationsRead() async throws -> Int
    /// `POST /api/v1/me/devices` with `platform: ios` and the APNs device token (hex).
    func registerDevice(token: String) async throws
    /// `DELETE /api/v1/me/devices` with the token, on signing out.
    func unregisterDevice(token: String) async throws

    // MARK: Events

    /// `GET /api/v1/me/events/{hosting|upcoming|invitations|declined|past}`
    func events(_ list: EventListKind, page: PageRequest) async throws -> EventList
    /// `GET /api/v1/events/{id}`
    func event(id: Event.ID) async throws -> Event
    /// `POST /api/v1/events`
    func createEvent(_ draft: EventDraft) async throws -> Event
    /// `PATCH /api/v1/events/{id}`
    func updateEvent(id: Event.ID, with draft: EventDraft) async throws -> Event
    /// `PATCH /api/v1/events/{id}` with `status: cancelled` (the creator only).
    func cancelEvent(id: Event.ID) async throws -> Event
    /// `DELETE /api/v1/events/{id}`: gone for good, with no one told (the
    /// creator only). Suggest cancelling instead when people have answered.
    func deleteEvent(id: Event.ID) async throws
    /// `PATCH /api/v1/events/{id}` with `status: active`: back on (the creator only).
    func uncancelEvent(id: Event.ID) async throws -> Event
    /// `PUT /api/v1/events/{id}/cover`, the image's bytes as multipart
    /// `cover` (JPEG, PNG, WebP or HEIC, up to 15 MB). Hosts only.
    func setCover(eventId: Event.ID, imageData: Data) async throws -> Event
    /// `DELETE /api/v1/events/{id}/cover`. Hosts only.
    func deleteCover(eventId: Event.ID) async throws -> Event

    // MARK: Guests

    /// `GET /api/v1/events/{id}/guests?status=`. Pass a status to see only
    /// those; `invited` and `removed` are for hosts.
    func guestList(eventId: Event.ID, status: RSVPStatus?, page: PageRequest) async throws -> GuestList
    /// `PUT /api/v1/events/{id}/rsvp` with `going`, `maybe` or `not_going`
    /// and plus-ones (0 for `not_going`). The event comes back with your
    /// new `viewer.rsvp`, and `waitlisted` if going didn't fit.
    func setRSVP(eventId: Event.ID, status: RSVPStatus, guests: Int) async throws -> RSVPResult
    /// `DELETE /api/v1/events/{id}/rsvp`: invited again if a host invited
    /// you, otherwise off the list.
    func withdrawRSVP(eventId: Event.ID) async throws -> Event
    /// `POST /api/v1/events/{id}/invites` (hosts only)
    func invite(eventId: Event.ID, personIds: [Person.ID]) async throws -> InviteResult
    /// `DELETE /api/v1/events/{id}/invites/{personId}`: only while they
    /// haven't answered (hosts only).
    func uninvite(eventId: Event.ID, personId: Person.ID) async throws
    /// `GET /api/v1/people/lookup`: the person, or nil with no hint why.
    /// Verified people only.
    func lookUpPerson(_ lookup: PersonLookup) async throws -> Person?

    // MARK: Hosts and moderation

    /// `POST /api/v1/events/{id}/cohosts` (the creator only). Answers the
    /// event with them in `hosts`.
    func addCohost(eventId: Event.ID, personId: Person.ID) async throws -> Event
    /// `DELETE /api/v1/events/{id}/cohosts/{personId}`: the creator takes a
    /// co-host off, or a co-host steps down. They're left invited.
    func removeCohost(eventId: Event.ID, personId: Person.ID) async throws -> Event
    /// `PUT /api/v1/events/{id}/removed/{personId}` (hosts). Nobody is told.
    func removeGuest(eventId: Event.ID, personId: Person.ID) async throws
    /// `DELETE /api/v1/events/{id}/removed/{personId}`: they're left invited.
    func restoreGuest(eventId: Event.ID, personId: Person.ID) async throws
    /// `POST /api/v1/events/{id}/new-link` (the creator only). The event
    /// comes back under a new id; the old one is gone at once.
    func makeNewLink(eventId: Event.ID) async throws -> Event

    // MARK: Wall

    /// `GET /api/v1/events/{id}/wall`, newest first.
    func wall(eventId: Event.ID, page: PageRequest) async throws -> Wall
    /// `POST /api/v1/events/{id}/wall` with `{text}`. Answers the new entry.
    func postToWall(eventId: Event.ID, text: String) async throws -> WallEntry
    /// `DELETE /api/v1/events/{id}/wall/{entryId}`
    func deleteWallEntry(id: WallEntry.ID, eventId: Event.ID) async throws
}
