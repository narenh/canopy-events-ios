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
    /// `GET /api/v1/me/notifications`
    func notifications() async throws -> [InboxNotification]
    /// Mark one inbox entry read.
    func markNotificationRead(id: InboxNotification.ID) async throws

    // MARK: Events

    /// `GET /api/v1/me/events/{hosting|upcoming|invitations|declined|past}`
    func events(_ list: EventListKind, page: PageRequest) async throws -> EventList
    /// `GET /api/v1/events/{id}`
    func event(id: Event.ID) async throws -> Event
    /// `POST /api/v1/events`
    func createEvent(_ draft: EventDraft) async throws -> Event
    /// `PATCH /api/v1/events/{id}`
    func updateEvent(id: Event.ID, with draft: EventDraft) async throws -> Event
    /// `PATCH /api/v1/events/{id}` with `status: cancelled`
    func cancelEvent(id: Event.ID) async throws -> Event

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

    // MARK: Wall

    /// The event's activity wall, newest first.
    func wallPosts(eventId: Event.ID) async throws -> [WallPost]
    func addWallPost(eventId: Event.ID, body: String) async throws -> WallPost
    func deleteWallPost(id: WallPost.ID, eventId: Event.ID) async throws
}
