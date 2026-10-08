# Architecture

How the Canopy Events iOS app is put together, and how to add to it.
The product rules live in `canopy-events/docs/decisions.md`; the API
contract is `openapi.yaml` in the same repo (with `docs/api.md`), and the
account service's is `canopy-account-service/openapi.yaml` (with
`docs/native-api.md`). The models and both protocols match those specs.
This app is UI only for now:
**everything runs on in-memory mock data** behind two protocols, so the
real API can drop in later without touching a screen.

## Project settings

- Xcode 27, Swift 6 language mode (`SWIFT_VERSION = 6.0`), default actor
  isolation `MainActor`, approachable concurrency on. Strict concurrency
  is checked by the compiler; the app builds with zero warnings.
- Deployment target iOS 26.6 (also macOS and visionOS 26.6). **No iOS
  27-only API.** The target builds for iPhone, iPad, Mac and Vision.
- The `CanopyEvents/Events/` folder is a file-system synchronized group:
  any file or folder you add there is in the target. Never add files by
  editing `project.pbxproj`.
- `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor` is set,
  so the green accent applies to every system control.
- No third-party dependencies.

## Folder map

```
CanopyEvents/Events/
  App/          entry point, session, root switch, tabs, navigation routes
  Models/       plain value types shaped exactly like the APIs' JSON
  Data/         the seams: EventsRepository, AccountService, AuthToken, APIError,
                the API's JSON coders
    Mock/       the in-memory "server" and the mock implementations
    MockData/   sample people, events, posts, inbox; PreviewData for #Previews
  Features/     one folder per screen area (view + @Observable model)
  Components/   small reusable views (Avatar, EventCard, VerifyEmailBanner...)
  Design/       palette, spacing, radius, type, the mesh background, glass helpers,
                event colors (OKLCH, ThemeColors) and the hero's fade
  Utilities/    formatters and the platform shims
CanopyEvents/Shared/               compiled by the app and the notification extension:
                                   theme colors, cover art, the hero fade, palette,
                                   type and glass, the API's JSON coders, the App Group,
                                   the answer queue, and the expanded notification's card
CanopyEvents/NotificationContent/  the Notification Content Extension (iOS only)
CanopyEventsTests/  Swift Testing tests, not in a target yet (see Tests)
```

### App/

| File | Role |
| --- | --- |
| `CanopyEventsApp` | `@main`. Owns the `AppSession` (`AppSession.mock()` today). |
| `AppSession` | Who's signed in (`account: MeEnvelope?`), their `repository`, sign-in/out, verify, profile. Read with `@Environment(AppSession.self)`. |
| `AppSession+Mock` | Builds the all-mock session: one `MockBackend` shared by `MockAccountService` and every `MockEventsRepository`. |
| `RootView` | Signed out → `SignInView`; signed in → `MainTabView`, with the session's repository put in the environment. Forces dark mode. |
| `MainTabView` | The tabs (see below), one `NavigationStack` each, the new-event sheet. |
| `AppTab` | The tab values. |
| `Route` / `RouteView` | Every pushable screen as a `Hashable` value, and the one switch that maps it to a view. |
| `LaunchOptions` | Debug-only launch arguments to jump to a screen (below). |

### Tabs, and the host's app

Everyone gets **Events** (going, maybe, waitlisted; "Past events" link at
the top), **Invites** (unanswered invitations with Going / Can't Go on each card,
then, under "Declined", the upcoming events you said you can't go to,
each with your answer as a small "Can't Go" menu) and **Profile** (your
lists first, then your details and settings). There is no Friends or
Inbox tab: friends appear only in the invite sheet and "friends going",
and the inbox has a model and repository method but no screen (push will
cover it).

Hosting is progressive. `MeEnvelope.hasHosted` (exposed as
`session.isHost`) is the one switch:

- **Never hosted:** three tabs, and a "+" in the Events toolbar.
- **Hosted or co-hosted anything, ever** (past and cancelled count): a
  **Hosting** tab appears (upcoming hosted events, "Past" link at the
  top), and a **New event** button joins the tab bar. The Events "+"
  goes away. Hosted events live only in Hosting, never in Events.
- Creating your first event calls `session.refresh()`, `hasHosted` turns
  true, and the tabs change with an animation; the app then selects
  Hosting and pushes the new event.

The New event tab is a normal `Tab` whose selection is intercepted: the
`TabView` gets a custom `Binding` that opens the editor sheet instead of
switching tabs (`MainTabView.tabSelection`). iOS 27 adds
`Tab(role: .prominent)`, which also sets it apart visually; when the
deployment target reaches 27, add `role: .prominent` to that one `Tab`.
`tabViewBottomAccessory` was the other option, but it's meant for
persistent content like a mini player and is unavailable on visionOS and
macOS.

### Navigation

- Value-based: screens push `NavigationLink(value: Route.event(id))`, and
  each tab's stack has `.navigationDestination(for: Route.self) {
  RouteView(route: $0) }`. Routes carry **ids, not models**, so a pushed
  screen always loads fresh data.
- Sheets (editor, RSVP with plus-ones, the invite sheet, co-hosts, the
  host's lists, a list's QR code, verify email) are presented by the screen that owns them, with local
  `@State`. Sheets keep the system's sheet background, except the
  editor, which is drawn as the event and previews its color.
  `canopyScreen()` (the mesh) is otherwise for full screens.
- The sign-in flow has its own small stack and `SignInRoute`.
- Every tab's stack, Profile's included, maps `Route`s, so Profile can
  push one of your lists (`Route.ownList`) and a list's join screen
  (`Route.listLink`, what `/l/<code>` will open once the app claims it).

**To add a pushable screen:** make `Features/<Area>/<Name>View.swift`, add
a case to `Route`, add one line to `RouteView`. **To add a tab:** add a
case to `AppTab` and a `Tab` in `MainTabView` with its own
`NavigationStack` and the same `navigationDestination` line.

## Conventions

- **One type per file**, the file named after the type. Extensions are
  `Type+Topic.swift` (`MockEventsRepository+Guests.swift`,
  `View+GlassCard.swift`). A `private` helper used by only one file may
  sit beside it (the view modifier behind `.verifyEmailBanner()`).
- Files stay small (all under ~120 lines). Each type has a short doc
  comment saying what it's for.
- **Views** end in `View` when they're a screen (`GuestListView`),
  `Section` for a card on the event page (`AttendingSection`), `Sheet` for
  something presented modally, `Row`/`Card` for list items.
- **Every view has a `#Preview`** with mock data, including its key states
  (unverified, cancelled, waitlisted, hidden guest list, empty). Previews
  that need a signed-in app use `.mockEnvironment()` or
  `.mockEnvironment(signedInAs: MockPeople.sam)` (unverified with an
  invite) or `MockPeople.ada` (unverified, no history at all). Leaf views
  take plain values and use `PreviewData.event(MockEvents.rooftopId)`.
- **Models** are `nonisolated struct`s (or enums): `Codable`, `Hashable`,
  `Identifiable` where it makes sense. `nonisolated` because the module
  defaults to `MainActor`, and plain data shouldn't be tied to the main
  actor (a real API client may decode off it).
- Property names match the API's camelCase JSON exactly (`startsAt`,
  `guestListVisibility`, `emailVerified`...), so there are no
  `CodingKeys` except `APIError.message` (the JSON's `error`). Enum raw
  values are the API's strings (`RSVPStatus.notGoing = "not_going"`).
  Where a spec name would clash or read badly, the Swift type is named
  differently and its doc comment says so: `RSVPCounts` (`Counts`),
  `InboxNotification` (`Notification`), `RSVP` (`Rsvp`).
- Types the server says it will add to (`WallEntryType`,
  `NotificationType`) decode anything unknown as `.unknown`, which the
  app skips. Error codes are `APIErrorReason`, a string struct, for the
  same reason.
- **Other people are only ever `Person`** (id, names, shortName, photoUrl).
  Contact details exist only on `Me`, and only the Profile shows them.
- Colors, spacing, radii and fonts come from `Design/`, never bare
  numbers or hex. Type is `Typography`'s Dynamic Type styles (the web's
  scale and weights), never fixed point sizes, so accessibility sizes
  work. An event's colors come from `ThemeColors(event.theme)`. Liquid Glass goes through `glassCard()`,
  `glassSurface(cornerRadius:)`, `glassProminentButtonStyle()` and
  `glassButtonStyle()`, which fall back to visionOS's own glass. The few
  iPhone-only modifiers go through `Utilities/View+Platform.swift`. That
  keeps `#if os(...)` out of every screen.
- Use system components first: `List`, `Form`, `ContentUnavailableView`
  for empty states, `ShareLink`, `.confirmationDialog`, `.refreshable`.
  There's no custom empty-state view on purpose.

## The look, after the web

The event pages follow canopy-events' web designs (its
`docs/decision-log.md` from "Events web: friendlier design" on, and
`public/events.css` and `public/ui.js`). Where the web has an exact
rule, the app ports it and a test pins it to the web's own output.

- **Event colors.** `Event.theme` (`EventTheme`: Canopy green, a hue,
  or grey) gives `ThemeColors`: the mesh's base, five glows and the
  card tint, each worked out in OKLCH as docs/api.md says (`OKLCH`,
  Björn Ottosson's maths, chroma fitted into sRGB). `CanopyBackground`
  draws them as a 3×3 `MeshGradient`. Only the event page, its editor
  and the notification card are themed, and there the accent follows the
  event too (`.eventAccent(event.accent)`, read as
  `@Environment(\.eventAccent)`): `AccentColors`, the web's `accentTrio`
  line for line (each hue's own accent at its most vivid lightness, kept
  at 5:1 for the dark text on it), or for a grey event its `accentHue`'s
  trio or white (links then bold and underlined, `accentLink`). Main
  buttons take the accent with its own text color
  (`accentProminentButtonStyle()`). Lists and every other screen stay
  Canopy green. Status badges (`StatusBadge`) use the fixed status
  colors everywhere, never the event's.
- **The hero** (`EventHeroView`): the cover, or the generated art
  (`CoverArt`, the web's `coverArt` number for number), in a 3:2 frame
  edge to edge on a phone. Its top 2:1 is clear, with the how-soon pill
  (`RelativePill`, the web's `relativeWhen`) low on the left; then the
  picture fades itself out into the dark mesh with a mask (`heroFade`,
  the web's nine stops as transparency, nothing drawn over the photo).
  Pulled down, the picture stays put and the title and the rest slide
  over it (`pinnedWhilePulled`). The title starts on the band (the last sixth
  of the width), then the big date and time (`EventHeadView`). From a
  700 pt wide screen the page is a 680 pt column and the hero has 18 pt
  top corners.
- **The top section** (`EventInfoSection`): place, hosts, spots and
  description, with **no card or border** (the owner's call for iOS).
- **Then** the RSVP card or the host's controls (`HostControlsSection`:
  Share link + Invite, then Edit + a ⋯ menu), **Attending** (counts,
  View all, one row of faces ending in +N) and the wall.
- **Covers are downloaded at the size they're drawn** (`CoverSize`, as
  docs/api.md says), through `CoverPicture`.
- **The editor** is drawn as the event: the hero with its photo
  buttons, the title on the band, the when as big as the page's (each
  piece tapped for its picker), the zone by name with a Change menu
  (`TimeZoneChoices`, the web's `nearbyZones`), quiet dashed fields,
  the host's details (rows with ×, and "+ Link" … "+ Phone" chips,
  `EditorDetailsSection`), then the Guests and Color cards and a Save
  bar. The Color slider (`WheelSlider`) is the web's short grey stretch
  (12 steps) then the hue wheel, with Match photo as a picture icon on
  its label line; while Color is grey, an Accent slider (white, then the
  wheel) appears. Picking a photo works out its color (`PhotoHue`) and
  jumps the slider. No autofill on any editor field.
- **Lists** (`EventCard`): a 3:2 thumbnail, a bold accent date line
  ("SAT, OCT 10 · 7:30 PM"), the title, the place, a tag.
- **Type** (`Typography`): the web's scale as Dynamic Type styles, so
  accessibility sizes still scale (list cards stack at those sizes).

## Notifications

`Features/Notifications/` shows notifications with buttons. Local
notifications drive it today (the app is mocked); the same pieces serve
APNs pushes later. The payload the server should send is in
[docs/push-payloads.md](docs/push-payloads.md).

- `NotificationCategory` (`EVENT_INVITE`) and `NotificationAction`
  (`GOING`, `NOT_GOING`) are registered at launch.
- `NotificationResponder` is the notification center's delegate, made
  and registered in `CanopyEventsApp.init` so a tap that launches the
  app is caught. Going / Can't Go answer through the signed-in person's
  repository (`setRSVP`, no plus-ones) without opening the app, mark the
  inbox entry read, and call `session.dataChanged()`. A tap sets
  `opening`, which `MainTabView` turns into the event on Invites (an
  invitation) or Events. Banners show while the app is open too.
- `NotificationPayload` reads and writes the custom keys (`type`,
  `eventId`, `notificationId`, `eventTitle`, `actorId`, `actorName`);
  `NotificationWording` words an inbox entry as a title and body.
- `LocalNotifications.schedule(_:after:)` shows an inbox entry as a
  notification, through `CommunicationNotificationBuilder`, which donates
  an incoming `INSendMessageIntent` with the sender as an `INPerson`
  (their photo, or their initials drawn by `AvatarImage`) so the
  notification shows who sent it, Messages-style. This needs the
  Communication Notifications capability
  (`CanopyEvents.entitlements`) and `INSendMessageIntent` in
  `NSUserActivityTypes` (`CanopyEvents/Info.plist`, merged into the
  generated one).
- `NotificationPermission` asks once, after sign-in.
- Screens reload with `.task(id: session.dataVersion)`, which goes up
  after a notification's answer and whenever the app comes back to the
  front.
- **The expanded notification** is a Notification Content Extension,
  `CanopyEventsNotificationContent` (`com.canopysf.CanopyEvents.NotificationContent`,
  category `EVENT_INVITE`, user interaction on, the default content
  hidden), embedded in the app on iOS. Its `NotificationViewController`
  hosts `NotificationCardView` (in `Shared/`): the cover hero fading on
  the event's color, the title, the big date and time, the place, the
  faces going, and its own Going / Can't Go. What it draws comes in the
  notification (`userInfo["card"]`, a `NotificationCard`; the payload is
  in docs/push-payloads.md). An answer goes into the App Group's
  `AnswerQueue` (`group.com.canopysf.CanopyEvents`), the card shows a
  checkmark, and the notification closes; the app sends queued answers
  when it next becomes active (`NotificationResponder.applyQueuedAnswers`).
  Profile's Debug section can show the card inside the app.
- **Real pushes, still to do:** register with APNs and send the token
  (`registerDevice(token:)`); a Notification Service Extension that
  fetches the sender's photo (with the session token from a shared
  keychain) and runs `CommunicationNotificationBuilder`, since the app
  itself isn't running when a push arrives; marking read from the
  extension or on next launch.

## Where state lives

- **App-wide:** `AppSession` (`@Observable`, in the environment). Only
  sign-in, your account and the repository live here.
- **Per screen:** an `@Observable` model next to the view, created by the
  view as `@State` (`EventDetailModel`, `WallModel`, `EventEditorModel`...).
  Screens with trivial state (sign-in forms, sheets) use plain `@State`.
- **Models don't hold the repository.** The view reads
  `@Environment(\.eventsRepository)` and passes it in:
  `.task { await model.load(from: repository) }`. That keeps models free
  of environment plumbing and makes them easy to test.
- Loading happens in `.task` (cancelled automatically when the view goes
  away), and lists reload when you come back to them. Errors land in each
  model's `errorMessage` and show through `.errorAlert($model.errorMessage)`.
- Concurrent loads use `async let` (the event page loads the event, guest
  list and wall at once).

## The seams: repository and account service

```
 Screens ──@Environment(\.eventsRepository)──▶ any EventsRepository ──▶ MockEventsRepository ─┐
 Screens ──@Environment(AppSession.self)─────▶ AppSession ──▶ any AccountService ──▶ MockAccountService ─┤
                                                     └─ makeRepository(AuthToken) ─────────────────────┤
                                                                                                  MockBackend
```

- `EventsRepository` has one async method per `/api/v1` endpoint in
  openapi.yaml (each is commented with its method and path), returning
  the models. One-thing envelopes come back unwrapped (`{"event": …}` →
  `Event`, `{"entry": …}` → `WallEntry`, `{"unreadCount": n}` → `Int`,
  `{"ok": true}` → nothing); everything with more in it is a model
  (`RSVPResult`, `EventList`, `GuestList`, `Wall`, `NotificationList`...).
  Errors are `APIError`, the API's own `{error, reason, …}` shape.
- **Lists page.** Each list method takes a `PageRequest` (`.first`, or
  `.after(nextCursor)`) and answers a page with `nextCursor`.
  `EventsRepository+AllPages` follows the cursors for screens that show a
  whole list (`allEvents`, `allFriends`, `wholeGuestList`); the wall
  loads its newest page only.
- `AccountService` is the account service's native API: passkey sign-in;
  an emailed code, then a new passkey for an existing account or a new
  account; quick sign-up; verifying; your profile; sign-out. Each sign-in
  returns an `AuthToken`; `AppSession` turns the token into a repository
  with `makeRepository`.
- Both protocols are `AnyObject, Sendable`; implementations are
  main-actor classes (the module default), which are Sendable.

### How the mock works

- `MockBackend` is the pretend server: every account, event record, wall
  post and inbox, in memory, seeded from `MockData/`. It lives for the
  run: changes survive navigation and signing out and back in, and a
  fresh launch starts from the seed again. Every call waits a short fake
  delay (350 ms; previews use zero) so loading states show.
- `MockEventsRepository` answers as one person, split by topic into
  `+Hosting`, `+Covers`, `+Guests`, `+Invites`, `+Hosts` (co-hosts), `+Moderation`,
  `+Wall`, `+Notifications`, `+People` (lookup), `+Friends`,
  `+Suggested`, `+Lists` (your own), `+ListMemberships` (links, joining,
  leaving) and `+EventLists` (attaching). `MockRules` applies
  the server's rules from `docs/api.md`: guest list visibility (names
  only for hosts, `everyone`, or once you've answered), counts (people,
  plus-ones, and the two together), capacity and the waitlist (a `going`
  that doesn't fit becomes `waitlisted`; someone going who asks for more
  room than there is gets `no_room`; a freed spot promotes the earliest
  that fits), `guestsOverLimit`, removed people (out of the list and
  counts, the signed-out view for them), implicit friends, and which
  events go in which list. Hosts can't RSVP; cancelled and past events
  refuse answers; only the creator cancels, manages co-hosts and makes a
  new link.
- Lists page with real `nextCursor`s (`MockPaging`; the mock's cursor is
  an offset, the real one is opaque).
- The server's side effects are mocked too: the wall's own entries
  (`going`, `off_waitlist`, `time_changed`, `place_changed`, `cancelled`,
  `uncancelled`, `cohost_added`), and typed inbox entries for invites,
  answers (folded while unread), changes, cancelling, co-hosting,
  waitlist promotions and host posts. Nobody is told of their own doing.
  Wall and inbox ids are digits, like the real ones.
- `MockAccountService`: passkey sign-in is always Maya. Any email gets a
  "code"; **any six digits** pass. For `maya@example.com` or
  `sam@example.com` the code answers `existing` and signs in (verifying a
  quick account, as the real one does); for anyone else it answers
  `new`, and the screen points to quick sign-up. Quick sign-up with an
  email that has an account fails with `email_has_account`.
- Covers: the seed's are picsum.photos placeholders at the API's four
  sizes, each with a `coverHue`. An uploaded cover is kept in a temporary
  file (`MockCoverFile`) with its own size, and its color worked out on
  the device the way the server does (`PhotoHue`). Events come in
  several colors (blue, purple, teal, red, pink) and one grey.
- `hasHosted` stays true once you've hosted (`MockBackend.hostedPeople`),
  even after deleting the event; only hosts get `counts.invited`.
- Seed data (all dates relative to today, so it never goes stale):
  Maya (verified host) has events she's going to, maybe at, waitlisted
  for (a full supper club), invited to (one with a hidden guest list),
  declined, a cancelled one, a co-hosted birthday, a full game night she
  hosts with a waitlist, one in New York time with a long title, and
  six past events (three of them hers: two Drag Race nights and a
  bonfire).
  Sam is an unverified quick account with one invite and one RSVP.
- **Lists** (`MockBackend+Lists`, `+EventLists`, `+Suggested`, seeded
  from `MockLists`): Maya owns Drag Race (20 people, on her upcoming
  "Drag Race: the finale", which invited them) and Climbing (5); Ana owns
  Dumpling crew, on her rooftop dinner (Maya is going, so she's offered
  "Get invited next time") and on Dumpling night II (Maya isn't invited,
  so joining invites her to 1 event); Maya is on Lena's Supper club. Zane
  is on Drag Race but opted out of Maya's invitations. The rules are the
  API's: members are seen only by the owner (a member's owner calls are
  `list_not_found`), joining your own list is `own_list`, joining invites
  you to the list's events still to come, attaching invites everyone on
  it, and opt-outs, hosts and removed guests are skipped without a word.
  Suggestions are scored with the API's formula (each event together
  `2^(-days/90)`, doubled for yours; invitations 0.5, links and adds
  0.25, fading from when made, so `MockBackend.friendEdgeDates` keeps
  when each edge was made).
- 24 more people (`MockPeople+Crowd`), so Maya has 30-odd friends. Rosa
  is a findable account nobody knows yet: look her up in the invite
  sheet with (415) 555-0188 or @rosa.e.

### Launch options (debug builds only)

Set in the scheme's "Arguments Passed On Launch", or with
`xcrun simctl launch booted com.canopysf.CanopyEvents <args>`:

- `-mockAccount maya|quick|new`: skip sign-in as Maya, Sam (unverified),
  or a brand-new quick sign-up (Ada, no history, never hosted).
- `-mockTab events|invites|hosting|profile`
- `-mockEvent <id>`: push that event on the Events tab (ids are in
  `MockEvents+Upcoming.swift`, e.g. `4fQ9xKpL2mZa`).
- `-mockNewEvent YES`: open the new-event editor.
- `-mockEdit YES` with `-mockEvent <id>`: open that event's editor.
- `-mockNoPermission YES`: don't ask for notification permission (so
  the alert doesn't cover a screenshot).
- `-mockCard YES`: show the expanded notification's card (and don't ask
  for notification permission, so nothing covers it).
- `-mockTestNotification YES`: send the test notification (Adam Smith
  inviting you to Throw Eggs at Karl) 5 seconds after signing in, once
  notifications are allowed. Profile's "Debug (TestFlight only)" section
  has the same button, in debug builds and TestFlight.
- `-mockPush guests|wall` with `-mockEvent <id>`: that event's guest list
  or wall; `-mockPush past`: Past events; `-mockPush list`: Maya's Drag
  Race; `-mockPush listLink`: Ana's Dumpling crew's join screen.
- `-mockInvite YES` with `-mockEvent <id>`: open that event's invite
  sheet (e.g. `Gm8Night4Fun`, Board game night, or `Dr7FinaleSF9`, the
  finale with Drag Race on it).

## How the real API will slot in

1. Write `Data/API/APIEventsRepository.swift`: a class conforming to
   `EventsRepository`, holding the bearer token, calling `/api/v1` with
   `URLSession`, sending `PageRequest` as `?cursor=&limit=`, decoding with
   `JSONDecoder.eventsAPI` (it takes the API's millisecond times; the
   stock `.iso8601` strategy doesn't) and encoding bodies with
   `JSONEncoder.eventsAPI`. Unwrap the one-thing envelopes. Turn an
   `EventDraft` into `EventInput` (POST) or an `EventPatch` of only what
   changed (PATCH), empty strings as null. Decode error bodies as
   `APIError`. The cover is `multipart/form-data`, field `cover`.
2. Write `AccountServiceClient` conforming to `AccountService` against
   `account.canopysf.com/api/native/v1`: keep the ceremony from
   `auth/begin` between steps, make and use passkeys with ASAuthorization
   (relying party `canopysf.com`; the Associated Domains entitlement
   `webcredentials:canopysf.com`), and keep the token in the Keychain.
   Its answers decode with a plain `JSONDecoder` (its times are
   milliseconds, and the models here don't use any).
3. In `CanopyEventsApp`, replace `AppSession.mock()` with
   `AppSession(accounts: AccountServiceClient(), makeRepository: { APIEventsRepository(token: $0) })`.

No screen changes. Keep the mock for previews and tests.

## Mock vs real

**Matches the specs exactly** (names, optionality, nesting, enum
values), checked by decoding the specs' own examples
(`CanopyEventsTests/APIDecodingTests`):

- Events API models: `Person`, `Me` (no contact details: those are the
  account service's), `MeEnvelope` (`hasHosted`), `Event`
  (`details` (`EventDetail`, `EventDetailType`), `hiddenDetails`,
  `guestsAllowed`, `capacity`, `spotsLeft`, `coverImageUrl`,
  `coverImages` (`CoverImage`), `themeHue`, `themeGrayscale`,
  `accentHue`, `coverHue`, `coverGrayscale`, `viewer`, `friendsGoing`,
  `hostLists`, `joinableList`), `RSVPCounts`/`GuestCounts`
  (people, `guests`, `total`; `invited` nil for non-hosts), `Host`/`HostRole`, `RSVP` and `Guest` (`guestsOverLimit`),
  `RSVPStatus` (with `waitlisted` and `removed`), `Viewer` (`canPost`,
  `muted`), `FriendsGoing`, `RSVPResult`, `EventList`, `GuestList`,
  `Friend` (`source`, optional `lastTogetherAt`), `FriendList`,
  `SuggestedFriend` (`score`), the lists' `OwnedList`, `ListMember`/
  `ListMembers` (the spec's inline member), `ListMembership`,
  `ListLinkOwner` (the spec's `ListLink`, renamed because `ListLink` is
  a view here) with `ListName` and `ListLinkViewer`, `ListJoined`,
  `ListAttached`, `HostList`, `JoinableList` (all but `OwnedList` have
  no example in the spec, so their samples are built from the schemas),
  `FriendLink`, `FriendLinkOwner`, `Settings`, `InviteOptouts`,
  `EventDetailInput`, `WallEntry`/`WallEntryType`/`WallEntryDetails`, `Wall`
  (`wallVisible`, `canPost`), `InboxNotification`/`NotificationType`/
  `NotificationDetails`/`EventChange`, `EventSummary`,
  `NotificationList`, `InviteResult`/`SkippedInvite`/
  `SkippedInviteReason`, `APIError` (with `signIn`, `quickSignUp`,
  `verify`, `index`), and every `reason` both specs list
  (`APIErrorReason`).
- Every events endpoint for apps has a repository method: the six event
  lists (`all` and `declined` included), event CRUD and delete, cancel
  and un-cancel, cover upload and delete, answering (an answer changes,
  never goes back: there's no withdrawing), the guest list (with
  `?status=`), invite and uninvite, lookup (a POST), co-hosts, removal
  and restore, new link, the guest menu (mute, leave, invite opt-outs),
  friends (list, add, take out, friend link, reset, owner, accept),
  settings, the wall, the inbox (list, unread count, mark some or all
  read) and push devices.
- Account service: `EmailState`, and its `person` is `AccountProfile`
  (read with `profile(for:)`; the Profile and the verify sheet use it).
  `AccountService`'s methods map onto its sign-in, quick sign-up,
  verify, profile and sign-out steps.

**Still mock-only, or not modelled:**

- The mock itself: no network, no passkey, any six digits as a code,
  photos from pravatar.cc and covers from picsum.photos (offline,
  avatars fall back to initials and covers to the generated art). An
  uploaded cover lives in a temporary file, in one size. Lookup matches
  only the two accounts' own numbers and handles.
- `EventDraft` and `ProfileDraft` are form state, not the request
  bodies; the clients map them (above). `ProfileDraft.venmo` is sent as
  `venmoHandle`.
- Not modelled from the account service: the ceremony, the passkey
  options and responses (they live inside the client), passkey and
  session lists, changing the email (reauth), profile photo upload,
  sign-out everywhere. `AuthToken` is just the token: the sign-in
  answers' `person` is dropped, since the app loads you from events'
  `/me`.
- `/api/v1/openapi.yaml` (the document itself) and the site-to-site
  calendar route have no method.
- **Not built in the UI:** the name form after an emailed code for a
  new email (the screen points to quick sign-up), the "this takes over
  an unverified account" warning, friends screens (the list, adding by
  phone or Instagram, taking out, the friend link with its QR code, and
  opening someone's link at `/f/<code>`), un-inviting,
  removing and restoring guests (the web puts these behind View all),
  the inbox screen and badge, push
  registration, older wall pages, changing your photo, signed-out link
  previews, opening event links (universal links), persisting the
  sign-in across launches. (Built since: cover upload, colors,
  co-hosts, new link, cancel and bring back, delete; lists; lookup by
  phone or Instagram, in the invite sheet.)

## Tests

Swift Testing, in `CanopyEventsTests/`:

- `APIDecodingTests` decodes the specs' own examples (copied into
  `APISamples`) into the models and round-trips them through the API's
  encoder. When a spec changes, change `APISamples` with it.
- `ThemeColorTests` checks the color maths against the web's own
  output to the byte (theme colors at seven hues and grey, turning a
  green, the generated cover art, a photo's hue, the slider's scale);
  the expected values were made by running canopy-events'
  `public/ui.js` in node. `CoverSizeTests` checks picking a cover size.
  `EventWhenTests` the how-soon words, the big when, list lines,
  friendly zone names and the nearby zones; `EditorAndAttendingTests`
  the editor's rules and Attending's words and order.
- `NotificationCardTests`: the card built from an event (friends
  first, the 800 px cover), its trip through `userInfo`, its size, the
  test invite's content carrying a card the extension can read, and the
  reasons it can't.
- `NotificationTests`: the registered category and its buttons, the
  buttons' answers, the payload (including one as APNs delivers it), the
  test notification's words, and what Going, Can't Go and a tap do.
- `MockFlowTests` drives the mock flows end to end (lists and cursors,
  hidden guest lists and walls, plus-ones, the waitlist, code sign-in,
  quick sign-up, verifying, becoming a host, invites, state surviving
  sign-out); `MockHostFlowTests` the host side (co-hosts, removal, new
  links, creator-only cancel and delete, notification folding, lookup,
  invited counts).
- `MockListTests`: lists against docs/api.md (only the owner sees who's
  on one, joining your own fails, opening a link joins nobody, joining
  invites you to what's still to come and skips what's over or
  cancelled, attaching invites everyone on it but opt-outs, an opted-out
  joiner is on the list and nothing else, `hostLists` and
  `joinableList`, rename, reset, remove, leave, delete, the suggestions'
  order and score). `InvitePickerTests`: the invite sheet's "Invite all"
  ticks, who can't be picked, the tray's order, Suggested and A to Z,
  accent-blind search, what counts as a phone number or @username, and
  "Filter by past event" (its people A to Z, searched within, nobody
  ticked, a hidden guest list, its words, and loading it from the mock).

They're **not in a target yet**, because adding one means editing the
project file. They were last run (all 99 passing) through a throwaway
Swift package on macOS that links the non-UI sources with the same
Swift settings. To run them: in Xcode, File → New → Target
→ Unit Testing Bundle named `CanopyEventsTests` (Swift Testing), then
point it at the existing `CanopyEventsTests` folder.

## Decisions

Judgment calls made porting the web's designs (the services' own
decisions are in canopy-events' `docs/decision-log.md`):

- **No card at all around the event's top**, not even glass: the place,
  hosts and description sit straight on the event's mesh under the
  edge-to-edge hero (the owner's call; the web draws a fading outline).
- **The phone hero runs under the status bar and the back and share
  buttons** (the page ignores the top safe area); in the iPad column it
  sits below the bars with rounded top corners.
- **The mesh is a 3×3 `MeshGradient`, not five radial glows.** The
  colors are the web's to the byte; their placement is close (glow 1
  top left, 2 top right, 5 middle, 4 lower left, 3 low right) but not
  pixel-identical. The generated cover art likewise uses a linear and
  two elliptical gradients whose sizes only approximate CSS's.
- **The accent follows the event** on its page, editor and
  notification card (the web's change), through the environment, so it
  can't leak onto the lists. It also sets the tint, so prominent buttons
  and the selected answer turn; secondary glass buttons keep white words
  (`glassButtonStyle()` says so), rather than taking the tint. The
  colors match the web's to the byte (tests at seven hues, grey and
  green); the web checked dark text on the accent at every hue (at
  least 6.8:1).
- **Pull-down: the image stays put, and the content slides over it**
  (the owner's call, after a stretch-and-zoom was tried and dropped).
  While the page or editor is pulled down past its top, the hero's
  picture (cover, generated art, or the editor's with its buttons)
  keeps its place and size, pinned to the top; the pill, title and
  everything after rubber-band down as usual and are drawn over it.
  Scrolling up moves it all together, with no parallax. Checked in the
  simulator by shifting the page as a pull would (there's no Simulator
  app here to drag in).
- **The cover fades itself out; nothing is drawn over it** (the owner's
  call, replacing a dark gradient layer that travelled with the title
  and smeared a dark band across the photo when pulled down). The mesh
  is always dark, so the photo (or generated art) is masked from opaque
  to transparent over the web's fade band and the background shows
  through; its transparent foot stays with it when pinned. The title,
  the when and the pill keep soft shadows for legibility.
- **Glass everywhere, no solid grey.** Every card-like surface uses the
  event page's glass: lists of events are glass cards (`EventCardLink`)
  with glass links on top (`ListLink`), the guest list's groups are
  glass cards, and `List`/`Form` sections (profile, sign-in, the wall)
  get glass rows (`glassRowBackground()`) over the mesh. Sheets keep the
  system sheet background, with their lists' backgrounds hidden
  (`glassList()`) and glass rows. The guest list and wall use inline
  titles (they're second-level screens).
- **Notification buttons need the phone unlocked**
  (`.authenticationRequired`): an answer is seen by the host and the
  other guests, so it shouldn't be possible from someone else's hands on
  a locked phone. They don't open the app (no `.foreground`).
- **Permission is asked right after sign-in**, not at a cold launch:
  by then the app has shown what it's for, and invites are what it's
  about. Saying no changes nothing else (the inbox has everything); the
  Debug section says so if you try the test notification.
- **Answering from a notification brings no plus-ones**; the event page
  is where to add them. A tap opens an invitation on the Invites tab,
  anything else on Events.
- **Communication notifications are built in** (the owner's call, with
  the capability enabled on the App ID): the entitlement in
  `CanopyEvents.entitlements`, `INSendMessageIntent` in an `Info.plist`
  merged with the generated one. People without a photo get their
  initials drawn as the avatar. Adam Smith and Throw Eggs at Karl (always
  the coming 16 October, 7 PM) are in the mock for the test notification.
- **An invite reads "Adam Smith" over "10/16 · 7p · Throw Eggs at
  Karl"** (the owner's wording): the sender's name as the title, so it
  matches the avatar, and the when (`NotificationWhen`, on the event's
  clock) before the event's title. Exactly two buttons, Going (✓,
  `checkmark.circle.fill`) and Can't Go (`xmark.circle`), neither styled
  destructive: there's no Maybe, to discourage maybes.
- **A second target, added by hand to the project file.** The rule
  "never edit project.pbxproj" is for adding files (the synced folders
  do that); a target can't be added any other way without Xcode's UI.
  The extension is iOS only (content extensions don't exist on the Mac
  or Vision), so its embedding and dependency are filtered to iOS.
- **Code both targets use lives in `CanopyEvents/Shared/`**, a synced
  folder both compile, so nothing is duplicated: the theme colors, the
  cover art, the fade, the design tokens, the JSON coders, the card and
  the answer queue. The card takes plain values (`NotificationCard`),
  not the app's models, so the extension needs none of them.
- **The expanded card's data comes in the notification**, not from a
  snapshot of the app's: it's what a real push has to carry anyway (the
  extension runs before the app does), and it keeps the extension to a
  view. Only answers go the other way, through the App Group.
- **Answers from the card wait in the App Group** until the app is next
  active, because the mock's data lives in the app's process. A real
  build should send the answer from the extension straight to the API
  (with the session token in a shared keychain group) and drop the
  queue. Until then, an answer from the card reaches the host only when
  you next open the app; the Lock Screen's own buttons (which wake the
  app in the background) don't have that delay.
- **The system's buttons are hidden on the expanded card**
  (`notificationActions = []`): the card has its own, styled like the
  app's, and two pairs of the same buttons read as a mistake. They stay
  on the short look and the Lock Screen swipe, where there's no card.
- **The extension links UserNotificationsUI explicitly**
  (`OTHER_LDFLAGS = -framework UserNotificationsUI`). The first TestFlight
  build showed a blank card with the system's buttons under it: its
  `import UserNotificationsUI` was autolinked, and the linker drops an
  autolinked framework when no symbol in it is referenced (everything
  used is an Objective-C protocol or message), so the extension host
  couldn't find `_UNNotificationContentExtensionVendorContext` ("Unable
  to find NSExtensionContextClass… did you link the framework that
  declares the extension point?"), never connected the controller, and
  `didReceive` never ran. Found by running the extension in the
  simulator (a throwaway UI test that allows notifications, waits for
  the test invite and long-presses it) and reading its log.
- **The extension always hides the system's buttons, first thing**, and
  when a notification carries no card it can read, it shows the
  notification's own title and body with the same buttons, and logs why
  (`NotificationCard.read`, subsystem `com.canopysf.CanopyEvents`).
- **The notification's cover is 2:1, not 3:2.** iOS caps an expanded
  notification's height (about 380 pt on a 6.3" phone, seen in the
  simulator) and cuts off the top of anything taller; the full 3:2 card
  is about 450 pt. So the extension shows the hero's clear 2:1 part,
  sized for the notification's actual width (the card is measured at
  that width, not its ideal size, which loses the cover). The app's own
  view of the card stays 3:2.
- **The card hides the system's title and body**
  (`UNNotificationExtensionDefaultContentHidden`): the card says the
  same, bigger, with the cover.
- **Signing:** both App IDs (`com.canopysf.CanopyEvents` and
  `com.canopysf.CanopyEvents.NotificationContent`) and the App Group
  are registered; a local signed build used Xcode's team profiles for
  both, each with the group. If Xcode Cloud's signing fails on them, in
  the developer portal: Identifiers → App Groups → make sure
  `group.com.canopysf.CanopyEvents` exists; Identifiers →
  `com.canopysf.CanopyEvents` → App Groups on, with that group (and
  Communication Notifications on); Identifiers →
  `com.canopysf.CanopyEvents.NotificationContent` (create it if
  missing) → App Groups on, with that group.
- **The cover rides along as an attachment** (the 800 px size, or the
  generated art in the event's colors). Whether iOS shows it well next
  to the communication-notification avatar, or the avatar style loses
  out, still has to be checked on a phone; if it looks wrong, drop
  `NotificationCoverAttachment` from `LocalNotifications`.
- **Profile's Debug section shows in every build** (the owner's call:
  the app is in active development, so no gating). Gate it before the
  App Store, not before. Everything it calls (the test notification,
  Adam Smith and Throw Eggs at Karl) is compiled into every build; only launch
  arguments stay debug-only.
- **The home screen name is "Events"** (the owner's call;
  `INFOPLIST_KEY_CFBundleDisplayName`). The bundle id and product name
  are unchanged.
- **"View all" opens the existing guest list screen** rather than
  expanding in place (the web's `<details>`), the iOS way; the host's
  remove and restore tools are still to come there.
- **"Co-hosts…" opens a sheet** listing co-hosts (Remove) and friends
  (Add), saved at once. New link, Cancel, Bring back, Delete and Step
  down each ask first in a confirmation dialog; Delete says how many
  answered and that cancelling tells them, as the web's confirm does,
  then closes the page.
- **Attending's faces are 56 pt and scale with Dynamic Type**
  (`@ScaledMetric`), on iPad too (the web uses 64 px from 700 px), at
  least 5 pt apart, as many as fit.
- **The answer buttons are words only** (like the web), so they fit
  three across at large sizes.
- **The editor's pickers open in popovers** (a calendar for the date,
  wheels for the times, one date-and-time wheel for the end), since a
  native control can't be laid see-through over the big words as the
  web does. "+ End time" adds start + 3 h and opens its picker.
- **The editor's hero keeps the page's fade, with only a dashed line
  where the clear 2:1 ends** (the web's earlier editor dimmed the band
  instead; now that the editor is the event card, it shows what the
  page will).
- **Save is a prominent bar at the bottom; Close is in the toolbar.**
  The heading ("New Event"/"Edit Event") is read out, not shown.
  Cancelling moved from the editor to the page's ⋯ menu.
- **A picked photo's color is worked out on the device** with the
  server's algorithm (`PhotoHue`), so the slider jumps at once; the
  mock's upload stores the same. If the event saves but its cover
  upload fails, the editor stays open with the error, and Save tries
  again.
- **Time zone names are English** (`en_US` generic names with the
  web's overrides), like the rest of the app's words.
- **The how-soon pill is worked out when the page draws**, not ticked
  over while it's open (the web redraws it).
- **Not ported yet:** tinting list cards' glass with the event's color
  (the web does on home), the web's per-field error lines in the
  editor, the "can't be previewed" caption, the signed-out page, and
  restyling the wall, invite, profile and sign-in screens.

### Catching up with the web and the API (canopy-events 1755f46)

- **Contact details come from the Canopy Account service.** Events'
  `/me` no longer has them, so `Me` doesn't either; `AccountProfile` is
  the account service's person, loaded at sign-in and after every save
  or verify (`AppSession.profile`). The Profile waits for it.
- **Answers are never taken back** (the API dropped `DELETE /rsvp`):
  `withdrawRSVP` is gone. Leaving an event is the guest menu's "Remove
  me from event", which asks first.
- **The guest menu is a ⋯ on the RSVP card's heading line**, for anyone
  invited or answered (not hosts, not someone removed): Mute / Unmute,
  one "Opt out of invites from <first name>" (or "Allow invites
  from…") per host, and "Remove me from event" last. A muted event shows
  a small bell-slash beside the heading. Opt-outs are listed in Profile
  ("Not taking invites from") with Undo.
- **Invites matches the web's Invited tab**: invitation cards have
  Going / Can't Go (two buttons, even; the web's), and declined events
  are inline under a "Declined" heading. A declined card has no big
  button: your answer is a small "Can't Go" pill where the status badge
  would be (`AnswerMenuPill`), a menu of Can't Go (ticked), Going and
  Maybe; choosing one answers again. The separate Declined screen and its
  route are gone.
- **Event details** follow docs/api.md: link and phone on one line each,
  the rest a heading over text; only `http(s)` and `tel:` hrefs open;
  unknown types are skipped. The editor's chips scroll sideways on a
  phone. Empty rows aren't dropped on Save: the mock refuses them as the
  server does (`bad_detail_value`, with `index`).
- **Accents are the web's `accentTrio`**, ported line for line and
  checked at 16 hues against node. Main buttons take the accent's own
  text color (a bright accent has dark text, white has the grey base), as
  the web's do; before, they kept white words, which vanished on a white
  accent.
- **Status badges are fixed colors**, never the event's: Hosting
  (co-hosting too), Going, Maybe, "On the waitlist" (the docs' wording),
  Invited; Can't Go and Removed are plain glass. A cancelled event keeps
  its badge and adds "Cancelled".
- **No help text** (the copy rules in CLAUDE.md): the Profile's two
  footers went; "Contact (only you see these)" says it in the header.
  US spelling ("color") throughout, code and docs included
  (`EditorColorSection`).
- **The Events tab keeps its own lists** (upcoming, with hosting in its
  own tab); `/me/events/all` is in the repository for later.
- **"Wall" reads "Updates"** in everything people see (the heading, the
  screen, "Delete this post?" / "Delete this update?", "The host shows
  updates to people who've answered. Answer to see them."); the API's
  names (`/wall`, `wall_post`) and the code's `Wall…` types stay. Deleting
  now asks first, as on the web.
- **Every event-page card's heading is one size** (`Typography.sectionTitle`:
  RSVP, Hosting / Co-hosting, Attending, Updates).
- **Backgrounds (TMDB):** `GET /backgrounds` and `PUT .../cover/background`
  are in the repository; the mock has 11 of the real manifest's entries
  (TMDB thumbnail URLs, the server's base64url ids, made-up hues). The
  editor's hero gets a gallery button beside the camera (only when the set
  is on); its sheet is one grid with no title headings (each tile's
  VoiceOver label names its title and "n of count"), with TMDB's logo (a
  vector asset from the web's SVG) and credit at the foot. That foot is
  the only place the credit appears. Picking one previews
  it (the 780 px image) and jumps the color; Save sends it after the
  event is saved, as a picked photo is.
- **Not built:** the friends screens and friend links (models, repository
  and mock are done).

### Lists and the invite sheet (canopy-events ff7ed11)

The web's lists and inviter, mocked. Judgment calls:

- **Lists live at the top of Profile**, above your details: there's no
  Friends tab, and a list is something you open at a door, not set up
  once. Each opens its own screen (`OwnListView`): Share link and Show
  QR side by side, the link, then its people newest first with "Joined
  Oct 8"; swipe to remove (asked first, as the web does). Rename, Reset
  link and Delete are in the ⋯ menu (the web shows them as quiet links;
  Reset link is the web's, though the brief didn't list it). "Lists
  you're on" shows only when you're on any, each with Leave (asked
  first). A quick account sees "Confirm your email to make lists." in
  place of the field.
- **The QR code is drawn on the device** (`QRCode`, CoreImage's
  generator at level M with a four-module margin, drawn with no
  smoothing, as docs/api.md asks), in a sheet ("Scan to join") up to
  420 pt wide with the link under it; the web asks the server for an
  SVG instead. The same sheet is the host's "Show list QR" for every
  list on the event.
- **"Get invited next time" asks first** (a confirmation, "Join Ana's
  Dumpling crew?" / "Ana will be able to invite you to events."), as the
  brief asked; the web joins on one tap because its card already reads
  as the question. After joining, the card says "You're on Ana's
  Dumpling crew." and, when it brought any, "Ana invited you to 1 event."
- **The join screen (`/l/<code>`) has no "See your invitations"
  button** (the web's): the Invites tab is in the tab bar, and the app
  reloads it after joining (`session.dataChanged()`). Signed-out joining
  doesn't exist in the app, so its "Sign up to join" isn't ported.
  Profile's Debug section opens Ana's Dumpling crew's join screen.
- **The host's "Lists…" is a sheet** (the web's is a block in the host
  card), like Co-hosts…: the lists on the event with Take off (owner or
  creator), your others with Add (asked first when it has people on it),
  and a name field whose list goes on at once. "Show list QR" appears in
  the ⋯ menu once a list is on.
- **The invite sheet replaces the friends picker** (`InviteSheet`, at
  medium and large detents). Search is `.searchable`, always showing
  under the title, so the tray can own the foot. A whole phone number or
  @username is looked up 450 ms after typing stops, each text once, and
  the person is offered first under "Found"; names are never looked up.
  "Filter by past event" is a menu of your past events (the web's
  `<select>`; see "Inviter follow-ups" below). The picking
  rules are a plain value (`InvitePicker`) so they're tested without a
  screen. People on the event keep their row, greyed, with their
  `StatusBadge`, and aren't buttons.
- **"Invite all <n>" counts everyone on the list not on the event**,
  including someone who opted out of your invitations (the app can't
  know; the web can't either): sending skips them as the API does, so
  "Invite all 1" on the finale invites nobody (Zane). After sending, the
  sheet closes and the host card says "Invited 7 people." (nothing when
  nobody was invited, as on the web).
- **The sheet and "Lists…" take the event's accent** (`.eventAccent`),
  like the RSVP sheet, so "Invite 7" and a picked "Invite all" match the
  page's buttons; Profile's lists stay Canopy green.
- **One-key answers come back unwrapped**, as elsewhere: `GET /me/lists`
  is `[OwnedList]`, `/me/list-memberships` is `[ListMembership]`,
  `/me/friends/suggested` is `[SuggestedFriend]`. List members page like
  every other list (`allListMembers` follows the cursors).
- **The seed grew**: 24 more people, three more past events (two Drag
  Race nights Maya hosted, bouldering), two upcoming events with lists
  on them (Maya now hosts three upcoming events, so two counts in the
  older tests moved), and Rosa, a findable account to look up.
- **Launch arguments** reach the new screens for screenshots:
  `-mockInvite YES` with `-mockEvent`, and `-mockPush list|listLink`.

### Inviter follow-ups (canopy-events ad4df3d)

- **"Invite everyone from…" is now "Filter by past event"** and ticks
  nobody: it narrows the sheet to that event's hosts and going and maybe
  guests, A to Z under "From Beach bonfire", hiding lists and Suggested;
  typing searches within it. It's a menu-style `Picker` in its own row
  at the top of the list, right under the search field (above "Found";
  the web puts it below the lookup line). Off, it reads "Filter by past
  event … Everyone": "Everyone" is the first choice and clears it (the
  web's `<select>` shows "Filter by past event" as its first option
  until one is picked).
- **"Showing 4 from Beach bonfire." is only read out** (an
  accessibility announcement, as the web's is a live region); "No one
  else from …" and "… guest list isn't shown to you." are lines in the
  list. The count is everyone from that event, those already on this
  one (greyed) included, as on the web. The menu shows the choice at
  once and the list narrows when its people are in; if that fails, the
  menu goes back. Each event's people are fetched once per sheet.
- **A friend link is `person.2` inside the line's text** (an interpolated
  `Image` in `Text`, so it takes the line's size and secondary color and
  wraps with it), read as "Friend link". The line joins with ", ", no
  interpunct. Only the invite sheet shows a friend's line in the app:
  the friends screens aren't built and the co-host picker shows names
  only, so nothing else changed. `PersonRow` takes `isFriendLink` for
  when they are.
