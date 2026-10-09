/// Answers copied from the examples in canopy-events/openapi.yaml and
/// canopy-account-service/docs/native-api.md, as JSON. When the specs
/// change, change these with them.
enum APISamples {
    static let ana = #"{"id": "6f1c2b9e-4d0a-4a53-9a51-2f7e0c1d8b44", "firstName": "Ana", "lastName": "Lima", "shortName": "Ana L", "photoUrl": null}"#
    static let ben = #"{"id": "0b7e5a1f-9c2d-4e8b-8f3a-1d2c3b4a5e6f", "firstName": "Ben", "lastName": "Okafor", "shortName": "Ben O", "photoUrl": null}"#

    /// A host's counts; anyone else gets `"invited": null`.
    static let counts = #"""
    {"going": 4, "maybe": 1, "notGoing": 1, "invited": 3, "waitlisted": 0,
     "guests": {"going": 2, "maybe": 0, "waitlisted": 0},
     "total": {"going": 6, "maybe": 1, "waitlisted": 0}}
    """#

    /// `Event`'s example.
    static let event = """
    {"id": "4fQ9xKpL2mZa", "url": "https://events.canopysf.com/e/4fQ9xKpL2mZa", "title": "Rooftop dinner",
     "description": "Bring a jacket.", "startsAt": "2026-11-01T02:30:00.000Z", "endsAt": "2026-11-01T06:00:00.000Z",
     "timeZone": "America/Los_Angeles", "locationName": "Ana's place", "locationAddress": "1 Market St, San Francisco",
     "latitude": 37.794, "longitude": -122.3951, "applePlaceId": null, "locationAddressHidden": false,
     "details": [
       {"type": "link", "label": "Playlist", "value": "https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6", "href": "https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6"},
       {"type": "dress_code", "label": null, "value": "Warm layers", "href": null},
       {"type": "parking", "label": null, "value": "Street parking on Main; the garage closes at 11.", "href": null},
       {"type": "phone", "label": "Ana's cell", "value": "(415) 555-0142", "href": "tel:4155550142"},
       {"type": "hologram", "label": null, "value": "From the future", "href": null}],
     "hiddenDetails": 0, "guestListVisibility": "responded", "guestsAllowed": 1, "capacity": 20,
     "spotsLeft": 14, "coverImageUrl": "https://events.canopysf.com/covers/Qm7Zc2pR9xTa.jpg?v=1759870000000",
     "coverImages": [
       {"width": 400, "height": 300, "url": "https://events.canopysf.com/covers/Qm7Zc2pR9xTa-400.jpg?v=1759870000000"},
       {"width": 800, "height": 600, "url": "https://events.canopysf.com/covers/Qm7Zc2pR9xTa-800.jpg?v=1759870000000"},
       {"width": 1200, "height": 900, "url": "https://events.canopysf.com/covers/Qm7Zc2pR9xTa-1200.jpg?v=1759870000000"},
       {"width": 1600, "height": 1200, "url": "https://events.canopysf.com/covers/Qm7Zc2pR9xTa.jpg?v=1759870000000"}],
     "themeHue": null, "themeGrayscale": false, "accentHue": null, "coverHue": 24, "coverGrayscale": false,
     "status": "active", "cancelledAt": null, "createdAt": "2026-10-07T20:00:00.000Z", "updatedAt": "2026-10-07T20:00:00.000Z",
     "hosts": [{"person": \(ana), "role": "creator"}],
     "counts": \(counts),
     "viewer": {"role": null, "rsvp": {"status": "going", "guests": 1, "guestsOverLimit": false, "invited": true,
                "respondedAt": "2026-10-08T17:12:00.000Z"}, "canEdit": false, "canSeeGuestList": true, "canPost": true,
                "muted": false},
     "friendsGoing": {"count": 1, "people": [\(ben)]}}
    """

    /// `PUT /rsvp`'s `RsvpResult`.
    static let rsvpResult = #"{"event": \#(event), "waitlisted": false}"#

    /// `MeEnvelope`'s example.
    static let meEnvelope = """
    {"person": {"id": "6f1c2b9e-4d0a-4a53-9a51-2f7e0c1d8b44", "firstName": "Ana", "lastName": "Lima",
                "shortName": "Ana L", "photoUrl": null, "emailVerified": false, "findable": true},
     "verifyUrl": "https://account.canopysf.com/profile?verify=1&return=https%3A%2F%2Fevents.canopysf.com%2F",
     "hasHosted": false}
    """

    /// `GuestList`'s example.
    static let guestList = """
    {"guestsVisible": true,
     "guests": [{"person": \(ben), "status": "going", "guests": 1, "guestsOverLimit": false,
                 "respondedAt": "2026-10-08T17:12:00.000Z"}],
     "counts": {"going": 1, "maybe": 0, "notGoing": 0, "invited": null, "waitlisted": 0,
                "guests": {"going": 1, "maybe": 0, "waitlisted": 0}, "total": {"going": 2, "maybe": 0, "waitlisted": 0}},
     "nextCursor": null}
    """

    /// A `Wall` holding `WallEntry`'s example, a time change, and a type from the future.
    static let wall = """
    {"wallVisible": true, "canPost": true, "nextCursor": "WzMsIjA",
     "entries": [
       {"id": "42", "type": "post", "createdAt": "2026-10-08T17:12:00.000Z", "person": \(ben),
        "text": "Can't wait! I'll bring the cake.", "details": null, "canDelete": false},
       {"id": "43", "type": "time_changed", "createdAt": "2026-10-08T18:00:00.000Z", "person": \(ana), "text": null,
        "details": {"startsAt": "2026-11-01T03:00:00.000Z", "endsAt": null, "timeZone": "America/Los_Angeles"},
        "canDelete": true},
       {"id": "44", "type": "poll", "createdAt": "2026-10-08T19:00:00.000Z", "person": null, "text": null,
        "details": null, "canDelete": false}]}
    """

    /// A `NotificationList` holding `Notification`'s example.
    static let notifications = """
    {"unreadCount": 1, "nextCursor": null,
     "notifications": [{"id": "17", "type": "rsvp", "createdAt": "2026-10-08T17:12:00.000Z", "read": false,
       "actor": \(ben),
       "event": {"id": "4fQ9xKpL2mZa", "url": "https://events.canopysf.com/e/4fQ9xKpL2mZa", "title": "Rooftop dinner",
                 "startsAt": "2026-11-01T02:30:00.000Z", "timeZone": "America/Los_Angeles", "status": "active",
                 "coverImageUrl": null, "coverImages": [], "themeHue": 300, "themeGrayscale": false,
                 "accentHue": null},
       "details": {"status": "going"}, "count": 4}]}
    """

    /// The invite worked example, plus a removed person.
    static let inviteResult = """
    {"invited": [\(ben)],
     "skipped": [{"personId": "9a8b7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d", "reason": "not_found"},
                 {"personId": "6f1c2b9e-4d0a-4a53-9a51-2f7e0c1d8b44", "reason": "removed"}]}
    """

    /// `SignInRequired`'s example.
    static let signInRequired = """
    {"error": "sign in first", "reason": "sign_in_required",
     "signIn": "https://account.canopysf.com/?return=https%3A%2F%2Fevents.canopysf.com%2Fe%2F4fQ9xKpL2mZa",
     "quickSignUp": "https://account.canopysf.com/?quick=1&return=https%3A%2F%2Fevents.canopysf.com%2Fe%2F4fQ9xKpL2mZa"}
    """

    /// The account service: `auth/email/verify` for an existing account, and its `person`.
    static let emailState = #"{"verified": true, "state": "existing", "email": "ana@example.com", "firstName": "Ana", "hasPasskey": true, "unverified": false}"#
    static let accountPerson = """
    {"id": "6f1c2b9e-4d0a-4a53-9a51-2f7e0c1d8b44", "email": "ana@example.com", "emailVerified": true,
     "firstName": "Ana", "lastName": "Lima", "shortName": "Ana L",
     "photoUrl": "https://account.canopysf.com/photo/6f1c2b9e-4d0a-4a53-9a51-2f7e0c1d8b44?v=1759870000000",
     "venmo": "ana-l", "phone": "+14155551234", "instagram": "ana.lima", "cashapp": "AnaL", "findable": true, "isAdmin": false}
    """

    /// A page of friends: one from events together, one only added (no
    /// events in common, so `lastTogetherAt` is null).
    static let friends = """
    {"friends": [
       {"person": \(ana), "source": "shared_events", "eventsInCommon": 3, "lastTogetherAt": "2026-09-12T02:00:00.000Z"},
       {"person": \(ben), "source": "added", "eventsInCommon": 0, "lastTogetherAt": null}],
     "nextCursor": null}
    """

    static let friendLink = #"{"url": "https://events.canopysf.com/f/7Hq2mXc9LpRt", "code": "7Hq2mXc9LpRt"}"#
    static let friendLinkOwner = #"{"person": \#(ana), "viewer": {"isYou": false, "isFriend": true}}"#
    static let settings = #"{"calendarInvites": true}"#
    static let optouts = #"{"hosts": [\#(ben)]}"#
    static let detailError = #"{"error": "a link is a web address, starting http:// or https://", "reason": "bad_detail_url", "index": 1}"#

    /// `GET /api/v1/backgrounds`'s example.
    static let backgrounds = #"""
    {"enabled": true, "backgrounds": [
      {"id": "L2NnRlY3NjF3eE50UHhmVnNFVlNBTTV4RWtjRy5qcGc", "title": "Mean Girls", "year": null,
       "thumbUrl": "https://image.tmdb.org/t/p/w300/cgFV761wxNtPxfVsEVSAM5xEkcG.jpg",
       "previewUrl": "https://image.tmdb.org/t/p/w780/cgFV761wxNtPxfVsEVSAM5xEkcG.jpg",
       "width": 300, "height": 169, "hue": 35, "grayscale": false}]}
    """#
}
