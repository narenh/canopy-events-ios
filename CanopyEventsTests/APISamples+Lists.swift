/// The lists' answers: `OwnedList` is the spec's own example; the rest
/// are built field for field from openapi.yaml's schemas (`ListMembers`,
/// `ListMembersAdded`, `ListMembership`, `ListLink`, `ListJoined`,
/// `HostList`, `JoinableList`, `SuggestedFriends`), which have no
/// examples.
extension APISamples {
    static let ownedList = #"{"id": "Lq7Hn2xP0aZr", "name": "Drag Race", "code": "9xQ2mPc7LtRe", "url": "https://events.canopysf.com/l/9xQ2mPc7LtRe", "memberCount": 14, "createdAt": "2026-10-08T20:00:00.000Z"}"#
    static let ownedLists = #"{"lists": [\#(ownedList)]}"#
    static let listMembers = #"{"members": [{"person": \#(ana), "joinedAt": "2026-10-08T21:00:00.000Z", "source": "added"}, {"person": \#(ben), "joinedAt": "2026-10-07T21:00:00.000Z", "source": "link"}], "nextCursor": "WzMsIjA"}"#
    static let listMembersAdded = #"{"added": [\#(ana)], "alreadyOn": ["0b7e5a1f-9c2d-4e8b-8f3a-1d2c3b4a5e6f"], "skipped": [{"personId": "3c9d1e2f-0a1b-4c2d-8e3f-4a5b6c7d8e9f", "reason": "not_found"}, {"personId": "7a8b9c0d-1e2f-4a3b-9c4d-5e6f7a8b9c0d", "reason": "is_you"}], "invitedTo": 1, "list": \#(ownedList)}"#
    static let membership = #"{"id": "Lq7Hn2xP0aZr", "name": "Drag Race", "owner": \#(ben), "joinedAt": "2026-10-08T21:00:00.000Z"}"#
    static let listLink = #"{"list": {"name": "Drag Race"}, "owner": \#(ben), "viewer": {"isOwner": false, "isMember": false}}"#
    static let listLinkSignedOut = #"{"list": {"name": "Drag Race"}, "owner": \#(ben), "viewer": null}"#
    static let listJoined = #"{"list": \#(membership), "invitedTo": 2}"#
    static let hostList = #"{"id": "Lq7Hn2xP0aZr", "name": "Drag Race", "code": "9xQ2mPc7LtRe", "url": "https://events.canopysf.com/l/9xQ2mPc7LtRe", "owner": \#(ben), "isYours": false, "memberCount": null, "attachedAt": "2026-10-08T22:00:00.000Z"}"#
    static let joinableList = #"{"code": "9xQ2mPc7LtRe", "name": "Drag Race", "url": "https://events.canopysf.com/l/9xQ2mPc7LtRe", "owner": \#(ben)}"#
    static let suggested = #"{"friends": [{"person": \#(ana), "source": "invite", "eventsInCommon": 2, "lastTogetherAt": "2026-09-12T02:00:00.000Z", "score": 1.734}]}"#
}
