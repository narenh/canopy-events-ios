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
    /// `GET /api/v1/me/settings`
    func settings() async throws -> Settings
    /// `PATCH /api/v1/me/settings`: only what's set changes. Answers the settings after.
    func updateSettings(calendarInvites: Bool?) async throws -> Settings

    // MARK: Friends

    /// `GET /api/v1/me/friends`
    func friends(page: PageRequest) async throws -> FriendList
    /// `POST /api/v1/me/friends`: one way, they aren't told. Verified only.
    func addFriend(personId: Person.ID) async throws -> Friend
    /// `DELETE /api/v1/me/friends/{personId}`: out, and they stay out.
    func removeFriend(personId: Person.ID) async throws
    /// `GET /api/v1/me/friend-link`, made the first time.
    func friendLink() async throws -> FriendLink
    /// `POST /api/v1/me/friend-link/reset`: the old one stops working.
    func resetFriendLink() async throws -> FriendLink
    /// `GET /api/v1/friend-links/{code}`: whose it is. Adds nobody.
    func friendLinkOwner(code: String) async throws -> FriendLinkOwner
    /// `POST /api/v1/friend-links/{code}/accept`: friends both ways.
    func acceptFriendLink(code: String) async throws -> Friend
    /// `GET /api/v1/me/friends/suggested?limit=` (1 to 50): friends with a
    /// `score`, best first, not paginated. `{"friends": […]}` unwrapped.
    func suggestedFriends(limit: Int) async throws -> [SuggestedFriend]

    // MARK: Lists

    /// `GET /api/v1/me/lists`: yours, oldest first. `{"lists": […]}` unwrapped.
    func lists() async throws -> [OwnedList]
    /// `POST /api/v1/me/lists` with `{name}` (1 to 60). Verified only.
    func createList(name: String) async throws -> OwnedList
    /// `PATCH /api/v1/me/lists/{listId}` with `{name}`.
    func renameList(id: OwnedList.ID, name: String) async throws -> OwnedList
    /// `DELETE /api/v1/me/lists/{listId}`: gone, with its members and its
    /// place on events; invitations it made stay.
    func deleteList(id: OwnedList.ID) async throws
    /// `POST /api/v1/me/lists/{listId}/reset-link`: a new code and url;
    /// the old link stops working, members stay.
    func resetListLink(id: OwnedList.ID) async throws -> OwnedList
    /// `GET /api/v1/me/lists/{listId}/members`, newest first. The owner only.
    func listMembers(listId: OwnedList.ID, page: PageRequest) async throws -> ListMembers
    /// `DELETE /api/v1/me/lists/{listId}/members/{personId}`: they aren't told.
    func removeListMember(listId: OwnedList.ID, personId: Person.ID) async throws
    /// `GET /api/v1/me/list-memberships`: lists you're on, newest first.
    func listMemberships() async throws -> [ListMembership]
    /// `DELETE /api/v1/me/list-memberships/{listId}`: the owner isn't told.
    func leaveList(id: ListMembership.ID) async throws
    /// `GET /api/v1/list-links/{code}`: the list's name and owner. Joins nobody.
    func listLink(code: String) async throws -> ListLinkOwner
    /// `POST /api/v1/list-links/{code}/join`: on the list, and invited to
    /// its attached events still to come.
    func joinList(code: String) async throws -> ListJoined
    /// `PUT /api/v1/events/{id}/lists/{listId}`: a host puts one of their
    /// own lists on the event, which invites everyone on it.
    func attachList(eventId: Event.ID, listId: OwnedList.ID) async throws -> ListAttached
    /// `DELETE /api/v1/events/{id}/lists/{listId}`: nobody's invitation changes.
    func detachList(eventId: Event.ID, listId: OwnedList.ID) async throws -> Event

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

    /// `GET /api/v1/me/events/{all|hosting|upcoming|invitations|declined|past}`
    func events(_ list: EventListKind, page: PageRequest) async throws -> EventList
    /// `GET /api/v1/events/{id}`
    func event(id: Event.ID) async throws -> Event
    /// `POST /api/v1/events`. A copy sends `coverFrom` (its original's id)
    /// to start with its own copy of that cover.
    func createEvent(_ draft: EventDraft) async throws -> Event
    /// `GET /api/v1/events/{id}/duplicate-draft`: what a copy of an event
    /// you host starts with, to fill the new-event editor (no date or
    /// times). Nothing is made until `createEvent`. `{"draft": …}` unwrapped.
    func duplicateDraft(eventId: Event.ID) async throws -> DuplicateDraft
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
    /// `GET /api/v1/backgrounds`: the TMDB backdrops a host can choose.
    func backgrounds() async throws -> BackgroundList
    /// `PUT /api/v1/events/{id}/cover/background`: one becomes the cover,
    /// as an upload would. Hosts only.
    func setCoverBackground(eventId: Event.ID, backgroundId: Background.ID) async throws -> Event
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
    /// `POST /api/v1/events/{id}/invites` (hosts only)
    func invite(eventId: Event.ID, personIds: [Person.ID]) async throws -> InviteResult
    /// `DELETE /api/v1/events/{id}/invites/{personId}`: only while they
    /// haven't answered (hosts only).
    func uninvite(eventId: Event.ID, personId: Person.ID) async throws
    /// `POST /api/v1/people/lookup` (a POST, so the number or handle is
    /// never in a URL; don't log it): the person, or nil with no hint why.
    /// Verified people only.
    func lookUpPerson(_ lookup: PersonLookup) async throws -> Person?

    // MARK: The guest menu

    /// `PUT /api/v1/events/{id}/mute`: its chatter skips your inbox.
    func muteEvent(id: Event.ID) async throws -> Event
    /// `DELETE /api/v1/events/{id}/mute`
    func unmuteEvent(id: Event.ID) async throws -> Event
    /// `POST /api/v1/events/{id}/leave`: off the event for good (ask first).
    /// Answers the event as anyone with the link sees it.
    func leaveEvent(id: Event.ID) async throws -> Event
    /// `GET /api/v1/me/invite-optouts`
    func inviteOptouts() async throws -> InviteOptouts
    /// `PUT /api/v1/me/invite-optouts/{personId}`: their invitations are skipped.
    func optOutOfInvites(from personId: Person.ID) async throws
    /// `DELETE /api/v1/me/invite-optouts/{personId}`
    func optInToInvites(from personId: Person.ID) async throws

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
