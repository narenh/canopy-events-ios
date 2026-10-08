/// The answer to `PUT /api/v1/events/{id}/rsvp` (the API's `RsvpResult`):
/// the event after your answer (`viewer.rsvp` is it), and whether asking
/// for `going` put you on the waitlist because the event was full.
nonisolated struct RSVPResult: Codable, Hashable {
    var event: Event
    var waitlisted: Bool
}
