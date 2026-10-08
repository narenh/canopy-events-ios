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
  Design/       palette, spacing, radius, type, mesh background, glass helpers
  Utilities/    formatters and the platform shims
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
the top), **Invites** (unanswered invitations with answer buttons on each
card; "Declined" link at the top) and **Profile**. There is no Friends or
Inbox tab: friends appear only in the invite picker and "friends going",
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
- Sheets (editor, RSVP with plus-ones, invite friends, verify email) are
  presented by the screen that owns them, with local `@State`.
  Sheets keep the system's sheet background. `canopyScreen()` (the
  mesh) is for full screens only.
- The sign-in flow has its own small stack and `SignInRoute`.

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
  `Section` for a card on the event page (`HostsSection`), `Sheet` for
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
- Colours, spacing, radii and fonts come from `Design/`, never bare
  numbers or hex. Liquid Glass goes through `glassCard()`,
  `glassSurface(cornerRadius:)`, `glassProminentButtonStyle()` and
  `glassButtonStyle()`, which fall back to visionOS's own glass. The few
  iPhone-only modifiers go through `Utilities/View+Platform.swift`. That
  keeps `#if os(...)` out of every screen.
- Use system components first: `List`, `Form`, `ContentUnavailableView`
  for empty states, `ShareLink`, `.confirmationDialog`, `.refreshable`.
  There's no custom empty-state view on purpose.

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
  `+Hosting`, `+Guests`, `+Invites`, `+Hosts` (co-hosts), `+Moderation`,
  `+Wall`, `+Notifications` and `+People` (lookup). `MockRules` applies
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
- Seed data (all dates relative to today, so it never goes stale):
  Maya (verified host) has events she's going to, maybe at, waitlisted
  for (a full supper club), invited to (one with a hidden guest list),
  declined, a cancelled one, a co-hosted birthday, a full game night she
  hosts with a waitlist, one in New York time, and three past events.
  Sam is an unverified quick account with one invite and one RSVP.

### Launch options (debug builds only)

Set in the scheme's "Arguments Passed On Launch", or with
`xcrun simctl launch booted com.canopysf.CanopyEvents <args>`:

- `-mockAccount maya|quick|new`: skip sign-in as Maya, Sam (unverified),
  or a brand-new quick sign-up (Ada, no history, never hosted).
- `-mockTab events|invites|hosting|profile`
- `-mockEvent <id>`: push that event on the Events tab (ids are in
  `MockEvents+Upcoming.swift`, e.g. `4fQ9xKpL2mZa`).
- `-mockNewEvent YES`: open the new-event editor.

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

- Events API models: `Person`, `Me`, `MeEnvelope` (`hasHosted`), `Event`
  (`guestsAllowed`, `capacity`, `spotsLeft`, `coverImageUrl`, `viewer`,
  `friendsGoing`), `RSVPCounts`/`GuestCounts` (people, `guests`,
  `total`), `Host`/`HostRole`, `RSVP` and `Guest` (`guestsOverLimit`),
  `RSVPStatus` (with `waitlisted` and `removed`), `Viewer` (`canPost`),
  `FriendsGoing`, `RSVPResult`, `EventList`, `GuestList`, `Friend`,
  `FriendList`, `WallEntry`/`WallEntryType`/`WallEntryDetails`, `Wall`
  (`wallVisible`, `canPost`), `InboxNotification`/`NotificationType`/
  `NotificationDetails`/`EventChange`, `EventSummary`,
  `NotificationList`, `InviteResult`/`SkippedInvite`/
  `SkippedInviteReason`, `APIError` (with `signIn`, `quickSignUp`,
  `verify`), and every `reason` both specs list (`APIErrorReason`).
- Every events endpoint has a repository method: the five event lists
  (`declined` included), event CRUD, cancel and un-cancel, cover upload
  and delete, RSVP and withdraw, the guest list (with `?status=`),
  invite and uninvite, lookup, co-hosts, removal and restore, new link,
  the wall, the inbox (list, unread count, mark some or all read) and
  push devices.
- Account service: `EmailState`, and its `person` decodes as `Me`.
  `AccountService`'s methods map onto its sign-in, quick sign-up,
  verify, profile and sign-out steps.

**Still mock-only, or not modelled:**

- The mock itself: no network, no passkey, any six digits as a code,
  photos from pravatar.cc and covers from picsum.photos (offline,
  avatars fall back to initials and covers to a green gradient). Cover
  upload keeps no bytes. Lookup matches only the two accounts' own
  numbers and handles.
- `EventDraft` and `ProfileDraft` are form state, not the request
  bodies; the clients map them (above). `ProfileDraft.venmo` is sent as
  `venmoHandle`.
- Not modelled from the account service: the ceremony, the passkey
  options and responses (they live inside the client), passkey and
  session lists, changing the email (reauth), profile photo upload,
  sign-out everywhere. `AuthToken` is just the token: the sign-in
  answers' `person` is dropped, since the app loads you from events'
  `/me`.
- `/api/v1/openapi.yaml` (the document itself) has no method.
- **Not built in the UI:** the name form after an emailed code for a
  new email (the screen points to quick sign-up), the "this takes over
  an unverified account" warning, withdrawing an RSVP, un-inviting,
  un-cancelling, co-host management, host moderation (remove, restore,
  new link), cover upload (the editor shows a placeholder), lookup by
  phone or Instagram, the inbox screen and badge, push registration,
  older wall pages, changing your photo, signed-out link previews,
  opening event links (universal links), persisting the sign-in across
  launches.

## Tests

Swift Testing, in `CanopyEventsTests/`:

- `APIDecodingTests` decodes the specs' own examples (copied into
  `APISamples`) into the models and round-trips them through the API's
  encoder. When a spec changes, change `APISamples` with it.
- `MockFlowTests` drives the mock flows end to end (lists and cursors,
  hidden guest lists and walls, plus-ones, the waitlist, code sign-in,
  quick sign-up, verifying, becoming a host, invites, state surviving
  sign-out); `MockHostFlowTests` the host side (co-hosts, removal, new
  links, creator-only cancel, notification folding, lookup).

They're **not in a target yet**, because adding one means editing the
project file. To run them: in Xcode, File → New → Target
→ Unit Testing Bundle named `CanopyEventsTests` (Swift Testing), then
point it at the existing `CanopyEventsTests` folder.
