/// Everything the app asks of the Canopy Events API, one method per
/// planned endpoint. Screens only ever talk to this protocol, through
/// `@Environment(\.eventsRepository)`.
///
/// Tonight the only implementation is `MockEventsRepository` (in-memory).
/// A real `APIEventsRepository` that calls `/api/v1` with a bearer token
/// slots in later without touching any screen. Methods throw `APIError`.
protocol EventsRepository: AnyObject, Sendable {
    // MARK: You

    /// `GET /api/v1/me`
    func me() async throws -> MeEnvelope
    /// `GET /api/v1/me/friends`
    func friends() async throws -> [Friend]
    /// `GET /api/v1/me/notifications`
    func notifications() async throws -> [InboxNotification]
    /// Mark one inbox entry read.
    func markNotificationRead(id: InboxNotification.ID) async throws

    // MARK: Events

    /// `GET /api/v1/me/events/{upcoming|invitations|hosting|past|declined}`
    func events(_ list: EventListKind) async throws -> [Event]
    /// `GET /api/v1/events/{id}`
    func event(id: Event.ID) async throws -> Event
    /// `POST /api/v1/events`
    func createEvent(_ draft: EventDraft) async throws -> Event
    /// `PATCH /api/v1/events/{id}`
    func updateEvent(id: Event.ID, with draft: EventDraft) async throws -> Event
    /// `PATCH /api/v1/events/{id}` with `status: cancelled`
    func cancelEvent(id: Event.ID) async throws -> Event

    // MARK: Guests

    /// `GET /api/v1/events/{id}/guests`
    func guestList(eventId: Event.ID) async throws -> GuestList
    /// `PUT /api/v1/events/{id}/rsvp`. Returns the event with your new `viewer.rsvp`.
    func setRSVP(eventId: Event.ID, status: RSVPStatus, guests: Int) async throws -> Event
    /// `DELETE /api/v1/events/{id}/rsvp`
    func withdrawRSVP(eventId: Event.ID) async throws -> Event
    /// `POST /api/v1/events/{id}/invites` (hosts only)
    func invite(eventId: Event.ID, personIds: [Person.ID]) async throws -> InviteResult

    // MARK: Wall

    /// The event's activity wall, newest first.
    func wallPosts(eventId: Event.ID) async throws -> [WallPost]
    func addWallPost(eventId: Event.ID, body: String) async throws -> WallPost
    func deleteWallPost(id: WallPost.ID, eventId: Event.ID) async throws
}
