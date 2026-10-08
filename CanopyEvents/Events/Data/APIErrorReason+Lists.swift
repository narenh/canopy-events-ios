/// The `reason`s the events API's lists add (openapi.yaml, tag Lists).
nonisolated extension APIErrorReason {
    /// A list's name isn't 1 to 60 characters.
    static let badName = Self(rawValue: "bad_name")
    /// Someone else's list, or none: whether it exists is its owner's business.
    static let listNotFound = Self(rawValue: "list_not_found")
    /// A wrong or reset list link.
    static let listLinkNotFound = Self(rawValue: "list_link_not_found")
    static let notAMember = Self(rawValue: "not_a_member")
    /// Taking a co-host's list off an event when you aren't its creator.
    static let notYourList = Self(rawValue: "not_your_list")
    /// Joining your own list.
    static let ownList = Self(rawValue: "own_list")
    /// 50 lists a person, or 10 on one event.
    static let tooManyLists = Self(rawValue: "too_many_lists")
    /// 1,000 people on a list.
    static let listFull = Self(rawValue: "list_full")
}
