/// Every `reason` the events API's openapi.yaml lists, by status.
nonisolated extension APIErrorReason {
    // MARK: 400: fix the request (most are form errors to show)

    static let badJSON = Self(rawValue: "bad_json")
    static let badTitle = Self(rawValue: "bad_title")
    static let badStartsAt = Self(rawValue: "bad_starts_at")
    static let badEndsAt = Self(rawValue: "bad_ends_at")
    static let endsBeforeStart = Self(rawValue: "ends_before_start")
    static let badTimeZone = Self(rawValue: "bad_time_zone")
    static let badGuestListVisibility = Self(rawValue: "bad_guest_list_visibility")
    static let badDescription = Self(rawValue: "bad_description")
    static let badLocationName = Self(rawValue: "bad_location_name")
    static let badLocationAddress = Self(rawValue: "bad_location_address")
    /// Half a pin, out of range, or a pin with no name or address.
    static let badCoordinates = Self(rawValue: "bad_coordinates")
    static let badApplePlaceId = Self(rawValue: "bad_apple_place_id")
    /// Places autocomplete's `near` (the server's places, not used on iOS).
    static let badNear = Self(rawValue: "bad_near")
    static let badStatus = Self(rawValue: "bad_status")
    static let badGuests = Self(rawValue: "bad_guests")
    static let tooManyGuests = Self(rawValue: "too_many_guests")
    static let badGuestsAllowed = Self(rawValue: "bad_guests_allowed")
    static let badPersonIds = Self(rawValue: "bad_person_ids")
    static let badPersonId = Self(rawValue: "bad_person_id")
    static let badText = Self(rawValue: "bad_text")
    static let badCapacity = Self(rawValue: "bad_capacity")
    static let badImage = Self(rawValue: "bad_image")
    /// A background id that isn't in the current set: fetch the list again.
    static let badBackground = Self(rawValue: "bad_background")
    static let badIds = Self(rawValue: "bad_ids")
    static let badPlatform = Self(rawValue: "bad_platform")
    static let badToken = Self(rawValue: "bad_token")
    static let oneOf = Self(rawValue: "one_of")
    static let badPhone = Self(rawValue: "bad_phone")
    static let badInstagram = Self(rawValue: "bad_instagram")
    static let badCursor = Self(rawValue: "bad_cursor")
    static let badLimit = Self(rawValue: "bad_limit")
    static let badThemeHue = Self(rawValue: "bad_theme_hue")
    static let badThemeGrayscale = Self(rawValue: "bad_theme_grayscale")
    static let badAccentHue = Self(rawValue: "bad_accent_hue")
    static let accentNeedsGrayscale = Self(rawValue: "accent_needs_grayscale")
    /// A copy's `coverFrom` that isn't an event (or no longer is).
    static let badCoverFrom = Self(rawValue: "bad_cover_from")
    /// A copy's original has no cover now: another host took it off.
    static let noCover = Self(rawValue: "no_cover")
    static let badDetails = Self(rawValue: "bad_details")
    static let tooManyDetails = Self(rawValue: "too_many_details")
    /// With `index`: which detail.
    static let badDetail = Self(rawValue: "bad_detail")
    static let badDetailType = Self(rawValue: "bad_detail_type")
    static let badDetailLabel = Self(rawValue: "bad_detail_label")
    static let badDetailValue = Self(rawValue: "bad_detail_value")
    static let badDetailURL = Self(rawValue: "bad_detail_url")
    static let badDetailPhone = Self(rawValue: "bad_detail_phone")
    static let detailTooLong = Self(rawValue: "detail_too_long")
    static let badSettings = Self(rawValue: "bad_settings")
    static let unknownSetting = Self(rawValue: "unknown_setting")
    static let badCalendarInvites = Self(rawValue: "bad_calendar_invites")
    /// Any route, for a request that can't be read at all.
    static let badRequest = Self(rawValue: "bad_request")

    // MARK: 401 and 403

    static let signInRequired = Self(rawValue: "sign_in_required")
    static let emailUnverified = Self(rawValue: "email_unverified")
    static let hostsOnly = Self(rawValue: "hosts_only")
    static let creatorOnly = Self(rawValue: "creator_only")
    static let answerFirst = Self(rawValue: "answer_first")
    static let notYours = Self(rawValue: "not_yours")
    static let lookupNotAllowed = Self(rawValue: "lookup_not_allowed")
    static let badOrigin = Self(rawValue: "bad_origin")

    // MARK: 404

    static let eventNotFound = Self(rawValue: "event_not_found")
    static let notInvited = Self(rawValue: "not_invited")
    static let personNotFound = Self(rawValue: "person_not_found")
    static let notCohost = Self(rawValue: "not_cohost")
    static let entryNotFound = Self(rawValue: "entry_not_found")
    static let notRemoved = Self(rawValue: "not_removed")
    static let notFound = Self(rawValue: "not_found")
    static let notAFriend = Self(rawValue: "not_a_friend")
    static let friendLinkNotFound = Self(rawValue: "friend_link_not_found")
    /// A place id that isn't a suggestion's (the server's places).
    static let placeNotFound = Self(rawValue: "place_not_found")

    // MARK: 409: not in this event's state, so redraw from the event

    static let eventCancelled = Self(rawValue: "event_cancelled")
    static let eventOver = Self(rawValue: "event_over")
    static let hostCannotRSVP = Self(rawValue: "host_cannot_rsvp")
    static let alreadyResponded = Self(rawValue: "already_responded")
    static let isCreator = Self(rawValue: "is_creator")
    static let tooManyCohosts = Self(rawValue: "too_many_cohosts")
    static let noRoom = Self(rawValue: "no_room")
    static let removed = Self(rawValue: "removed")
    static let isHost = Self(rawValue: "is_host")
    /// Muting or leaving an event you aren't on.
    static let notOnEvent = Self(rawValue: "not_on_event")
    /// Adding, linking or opting out of yourself.
    static let isYou = Self(rawValue: "is_you")
    /// Accepting your own friend link.
    static let ownLink = Self(rawValue: "own_link")

    // MARK: Everything else

    static let tooLarge = Self(rawValue: "too_large")
    static let rateLimited = Self(rawValue: "rate_limited")
    /// TMDB didn't give the background just now: try again in a minute.
    static let backgroundUnreachable = Self(rawValue: "background_unreachable")
    static let accountsUnreachable = Self(rawValue: "accounts_unreachable")
    /// Apple Maps couldn't be asked, or places are off: let the host type it.
    static let placesUnavailable = Self(rawValue: "places_unavailable")
    static let serverError = Self(rawValue: "server_error")
}
