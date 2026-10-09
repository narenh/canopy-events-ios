import Foundation
import Testing
@testable import CanopyEvents

/// The spec's own examples (`APISamples`) decode into the models, and
/// survive a round trip through the API's encoder. Not in a target yet,
/// like `MockFlowTests` (see ARCHITECTURE.md, "Tests").
struct APIDecodingTests {
    private func decode<T: Codable & Equatable & Sendable>(_ type: T.Type, _ json: String) throws -> T {
        let value = try JSONDecoder.eventsAPI.decode(T.self, from: Data(json.utf8))
        let again = try JSONDecoder.eventsAPI.decode(T.self, from: JSONEncoder.eventsAPI.encode(value))
        #expect(again == value, "\(T.self) changed in a round trip")
        return value
    }

    @Test func event() throws {
        let event = try decode(Event.self, APISamples.event)
        #expect(event.guestsAllowed == 1 && event.capacity == 20 && event.spotsLeft == 14)
        #expect(event.counts.total.going == 6 && event.counts.guests.going == 2)
        #expect(event.viewer?.rsvp?.guestsOverLimit == false && event.viewer?.canPost == true)
        #expect(event.viewer?.role == nil && event.hosts.first?.role == .creator)
        #expect(event.friendsGoing?.people.first?.shortName == "Ben O")
        #expect(event.startsAt == Date(timeIntervalSince1970: 1_793_500_200))
        #expect(event.coverImages.count == 4 && event.coverImages.last?.url == event.coverImageUrl)
        #expect(event.theme == .canopyGreen && event.coverTheme == .hue(24) && event.accentHue == nil)
        #expect(event.details.map(\.type) == [.link, .dressCode, .parking, .phone, .unknown])
        #expect(event.shownDetails.count == 4 && event.viewer?.muted == false)
        #expect(event.details[0].linkText == "Playlist" && event.details[1].heading == "Dress code")
        #expect(event.details[3].url?.absoluteString == "tel:4155550142")
    }

    @Test func rsvpResult() throws {
        let result = try decode(RSVPResult.self, APISamples.rsvpResult)
        #expect(!result.waitlisted && result.event.myStatus == .going)
    }

    @Test func me() throws {
        let me = try decode(MeEnvelope.self, APISamples.meEnvelope)
        #expect(!me.person.emailVerified && !me.hasHosted && me.verifyUrl != nil)
    }

    @Test func guestList() throws {
        let list = try decode(GuestList.self, APISamples.guestList)
        #expect(list.guests.first?.status == .going && list.nextCursor == nil)
        #expect(list.counts.invited == nil)
    }

    @Test func wallKeepsUnknownTypesOut() throws {
        let wall = try decode(Wall.self, APISamples.wall)
        #expect(wall.entries.map(\.type) == [.post, .timeChanged, .unknown])
        #expect(wall.entries[1].details?.endsAt == nil && wall.entries[1].details?.timeZone == "America/Los_Angeles")
        #expect(wall.entries.filter(\.isKnown).count == 2 && wall.nextCursor == "WzMsIjA")
        #expect(WallEntryText.string(for: wall.entries[2]) == nil)
    }

    @Test func notifications() throws {
        let list = try decode(NotificationList.self, APISamples.notifications)
        let item = try #require(list.notifications.first)
        #expect(item.type == .rsvp && item.count == 4 && item.details?.status == .going)
        #expect(item.event?.id == "4fQ9xKpL2mZa" && list.unreadCount == 1)
        #expect(item.event?.themeHue == 300 && item.event?.coverImages == [])
    }

    @Test func inviteResult() throws {
        let result = try decode(InviteResult.self, APISamples.inviteResult)
        #expect(result.skipped.map(\.reason) == [.notFound, .removed])
    }

    @Test func errors() throws {
        let error = try decode(APIError.self, APISamples.signInRequired)
        #expect(error.reason == .signInRequired && error.signIn != nil && error.quickSignUp != nil)
        #expect(error.message == "sign in first")
    }

    @Test func accountService() throws {
        let state = try decode(EmailState.self, APISamples.emailState)
        #expect(state.state == .existing && state.unverified == false)
        let profile = try decode(AccountProfile.self, APISamples.accountPerson)
        #expect(profile.findable && profile.photoUrl != nil && profile.phone == "+14155551234" && !profile.isAdmin)
        #expect(profile.me.id == profile.id)
    }

    @Test func friendsAndTheirLinks() throws {
        let list = try decode(FriendList.self, APISamples.friends)
        #expect(list.friends.map(\.source) == [.sharedEvents, .added])
        #expect(list.friends[1].eventsInCommon == 0 && list.friends[1].lastTogetherAt == nil)
        #expect(try decode(FriendLink.self, APISamples.friendLink).code == "7Hq2mXc9LpRt")
        #expect(try decode(FriendLinkOwner.self, APISamples.friendLinkOwner).viewer?.isFriend == true)
    }

    @Test func listsAndSuggestions() throws {
        #expect(try decode(OwnedList.self, APISamples.ownedList).memberCount == 14)
        #expect(try JSONDecoder.eventsAPI.decode([String: [OwnedList]].self, from: Data(APISamples.ownedLists.utf8))["lists"]?.count == 1)
        let members = try decode(ListMembers.self, APISamples.listMembers).members
        #expect(members.map(\.person.firstName) == ["Ana", "Ben"] && members.map(\.source) == [.added, .link])
        let added = try decode(ListMembersAdded.self, APISamples.listMembersAdded)
        #expect(added.added.first?.firstName == "Ana" && added.alreadyOn.count == 1 && added.invitedTo == 1)
        #expect(added.skipped.map(\.reason) == [.notFound, .isYou] && added.list.memberCount == 14)
        #expect(try decode(ListLinkOwner.self, APISamples.listLink).viewer?.isOwner == false)
        #expect(try decode(ListLinkOwner.self, APISamples.listLinkSignedOut).viewer == nil)
        #expect(try decode(ListJoined.self, APISamples.listJoined).invitedTo == 2)
        #expect(try decode(HostList.self, APISamples.hostList).memberCount == nil)
        #expect(try decode(JoinableList.self, APISamples.joinableList).name == "Drag Race")
        let suggested = try JSONDecoder.eventsAPI.decode([String: [SuggestedFriend]].self, from: Data(APISamples.suggested.utf8))
        #expect(suggested["friends"]?.first?.score == 1.734)
        // A single event carries them; an event without the keys decodes them as nil.
        #expect(try decode(Event.self, APISamples.event).hostLists == nil)
    }

    @Test func settingsOptoutsAndDetailErrors() throws {
        #expect(try decode(Settings.self, APISamples.settings).calendarInvites)
        #expect(try decode(InviteOptouts.self, APISamples.optouts).hosts.first?.shortName == "Ben O")
        let error = try decode(APIError.self, APISamples.detailError)
        #expect(error.reason == .badDetailURL && error.index == 1)
    }

    @Test func duplicateDraft() throws {
        let envelope = try JSONDecoder.eventsAPI.decode([String: DuplicateDraft].self, from: Data(APISamples.duplicateDraft.utf8))
        let draft = try #require(envelope["draft"])
        #expect(draft.title == "Drag Race night" && draft.timeZone == "America/Los_Angeles" && draft.capacity == nil)
        #expect(draft.details.map(\.type) == [.dressCode] && draft.details.first?.label == nil)
        #expect(draft.themeHue == 320 && draft.coverFrom == "4fQ9xKpL2mZa" && draft.coverTheme == .hue(318))
        #expect(draft.coverImages.count == 2 && draft.coverImages.last?.url == draft.coverImageUrl)
        #expect(draft.lists == [DuplicateDraftList(id: "Lw3Kp9QzX2aB", name: "Drag Race")])
        // Round trip (details get new row ids, so compare the JSON's own fields).
        let again = try JSONDecoder.eventsAPI.decode(DuplicateDraft.self, from: JSONEncoder.eventsAPI.encode(draft))
        #expect(again.details.map(\.value) == draft.details.map(\.value))
        var same = again
        same.details = draft.details
        #expect(same == draft)
    }

    @Test func backgrounds() throws {
        let list = try decode(BackgroundList.self, APISamples.backgrounds)
        #expect(list.enabled && list.backgrounds.first?.theme == .hue(35) && list.groups.count == 1)
        // The mock's ids are made the server's way.
        #expect(MockBackgrounds.all.first?.id == list.backgrounds.first?.id)
    }
}
