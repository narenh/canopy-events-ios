# Canopy Events for iOS

The iPhone, iPad, Mac and Vision app for Canopy Events
(`events.canopysf.com`): events among friends, shared by link, with
going / maybe / can't go, guest lists, plus-ones, a waitlist and an
activity wall.

**Right now it's UI only, on mock data.** Nothing talks to a server: every
screen goes through the `EventsRepository` and `AccountService` protocols,
and the only implementations are in-memory mocks. The models and those
protocols match the finished API specs, so the real clients drop in later
without touching a screen.

## Running it

Open `CanopyEvents/CanopyEvents.xcodeproj` in Xcode 27 and run the
`CanopyEvents` scheme on an iOS 26.6+ simulator. On the sign-in screen:

- **Sign in with passkey** signs in as Maya, a verified account who hosts.
- **Sign in with an email code**: `maya@example.com` or `sam@example.com`,
  then any six digits.
- **Quick sign-up** makes a new unverified account, with the
  verify-your-email banner (verify with any six digits).

Changes (RSVPs, posts, new events) last until the app quits. To skip
sign-in, pass launch arguments such as `-mockAccount maya -mockTab invites`
(see ARCHITECTURE.md).

## Where things are

See [ARCHITECTURE.md](ARCHITECTURE.md) for the folder map, conventions,
where state lives, how to add a screen, how the mock works, how the real
API slots in, and the list of mock-vs-real gaps.

Product decisions: `canopy-events/docs/decisions.md`. API contracts:
`canopy-events/openapi.yaml` (events) and
`canopy-account-service/openapi.yaml` (sign-in and profile).
