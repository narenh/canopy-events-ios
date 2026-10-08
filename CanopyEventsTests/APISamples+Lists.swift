/// The lists' answers: `OwnedList` is the spec's own example; the rest
/// are built field for field from openapi.yaml's schemas (`ListMembers`,
/// `ListMembership`, `ListLink`, `ListJoined`, `HostList`,
/// `JoinableList`, `SuggestedFriends`), which have no examples.
extension APISamples {
    static let ownedList = #"{"id": "Lq7Hn2xP0aZr", "name": "Drag Race", "code": "9xQ2mPc7LtRe", "url": "https://events.canopysf.com/l/9xQ2mPc7LtRe", "memberCount": 14, "createdAt": "2026-10-08T20:00:00.000Z"}"#
    static let ownedLists = #"{"lists": [\#(ownedList)]}"#
    static let listMembers = #"{"members": [{"person": \#(ana), "joinedAt": "2026-10-08T21:00:00.000Z"}], "nextCursor": "WzMsIjA"}"#
    static let membership = #"{"id": "Lq7Hn2xP0aZr", "name": "Drag Race", "owner": \#(ben), "joinedAt": "2026-10-08T21:00:00.000Z"}"#
    static let listLink = #"{"list": {"name": "Drag Race"}, "owner": \#(ben), "viewer": {"isOwner": false, "isMember": false}}"#
    static let listLinkSignedOut = #"{"list": {"name": "Drag Race"}, "owner": \#(ben), "viewer": null}"#
    static let listJoined = #"{"list": \#(membership), "invitedTo": 2}"#
    static let hostList = #"{"id": "Lq7Hn2xP0aZr", "name": "Drag Race", "code": "9xQ2mPc7LtRe", "url": "https://events.canopysf.com/l/9xQ2mPc7LtRe", "owner": \#(ben), "isYours": false, "memberCount": null, "attachedAt": "2026-10-08T22:00:00.000Z"}"#
    static let joinableList = #"{"code": "9xQ2mPc7LtRe", "name": "Drag Race", "url": "https://events.canopysf.com/l/9xQ2mPc7LtRe", "owner": \#(ben)}"#
    static let suggested = #"{"friends": [{"person": \#(ana), "source": "invite", "eventsInCommon": 2, "lastTogetherAt": "2026-09-12T02:00:00.000Z", "score": 1.734}]}"#
}
