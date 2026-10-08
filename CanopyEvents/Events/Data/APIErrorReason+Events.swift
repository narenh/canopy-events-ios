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
    static let badStatus = Self(rawValue: "bad_status")
    static let badGuests = Self(rawValue: "bad_guests")
    static let tooManyGuests = Self(rawValue: "too_many_guests")
    static let badGuestsAllowed = Self(rawValue: "bad_guests_allowed")
    static let badPersonIds = Self(rawValue: "bad_person_ids")
    static let badPersonId = Self(rawValue: "bad_person_id")
    static let badText = Self(rawValue: "bad_text")
    static let badCapacity = Self(rawValue: "bad_capacity")
    static let badImage = Self(rawValue: "bad_image")
    static let badIds = Self(rawValue: "bad_ids")
    static let badPlatform = Self(rawValue: "bad_platform")
    static let badToken = Self(rawValue: "bad_token")
    static let oneOf = Self(rawValue: "one_of")
    static let badPhone = Self(rawValue: "bad_phone")
    static let badInstagram = Self(rawValue: "bad_instagram")
    static let badCursor = Self(rawValue: "bad_cursor")
    static let badLimit = Self(rawValue: "bad_limit")

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

    // MARK: Everything else

    static let tooLarge = Self(rawValue: "too_large")
    static let rateLimited = Self(rawValue: "rate_limited")
    static let accountsUnreachable = Self(rawValue: "accounts_unreachable")
    static let serverError = Self(rawValue: "server_error")
}
