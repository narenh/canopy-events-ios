# Push payloads for the iOS app

What the events server should send to APNs so the app can show, act on
and route its notifications. The app already handles all of this
(`CanopyEvents/Events/Features/Notifications/`); today it's exercised by
local notifications, since the app is still mocked.

The custom keys match the message the events server already builds in
`lib/push.js` (`type`, `notificationId`, `eventId`, `eventTitle`,
`actorId`), and `type` is the inbox's `Notification.type` from
openapi.yaml.

## An invitation (with Going / Can't Go)

```json
{
  "aps": {
    "alert": { "title": "Adam Smith", "body": "10/16 · 7p · Throw Eggs at Karl" },
    "category": "EVENT_INVITE",
    "thread-id": "event-Eg1ThrowEggs",
    "sound": "default",
    "badge": 3,
    "mutable-content": 1
  },
  "type": "invited",
  "notificationId": "17",
  "eventId": "Eg1ThrowEggs",
  "eventTitle": "Throw Eggs at Karl",
  "actorId": "6f1c2b9e-4d0a-4a53-9a51-2f7e0c1d8b44",
  "actorName": "Adam Smith"
}
```

- `aps.alert`: the words. The title is who did it (or the event, for
  types about the event itself); the body is what happened. For an
  invitation the body is the when and the event: `M/d · time · title`,
  on the event's own clock, with `M/d/yy` when it isn't this year there,
  and the time as the hour plus `a` or `p`, with minutes only when they
  aren't :00 (`7p`, `7:30p`, `12p`, `12a`), joined by ` · ` (a middle
  dot, U+00B7, with spaces): `10/16 · 7p · Throw Eggs at Karl`. The
  app's `NotificationWhen` is the reference (and its tests the cases). The app
  words a local notification the same way (`NotificationWording`). If the
  senders move to `title-loc-key` / `loc-key` with arguments, the app
  needs matching keys in its strings; until then, send plain text.
- `aps.category`: `EVENT_INVITE` for `invited`. That gives the
  notification its two buttons, Going (`GOING`, ✓) and Can't Go
  (`NOT_GOING`, ✕), and only those two (no Maybe, on purpose), which answer the invitation in the background
  (`PUT /api/v1/events/{id}/rsvp`, no plus-ones). Other types send no
  category (no buttons) for now.
- `aps.thread-id`: `event-<eventId>`, so one event's notifications group
  together.
- `aps.badge`: the unread count, as `lib/push.js` already has it.
- `aps.mutable-content: 1`: lets the Notification Service Extension (to
  come, see ARCHITECTURE.md) add the sender's photo and attach the
  event's cover (the 800 px `coverImages` entry), as the app does for a
  local notification.
- `eventId` (required): which event. Without it the app ignores the
  buttons and the tap. A tap opens the event (on Invites for an
  invitation, Events otherwise).
- `notificationId`: the inbox entry, marked read when a button is used.
  A string, though a number is accepted.
- `type`: the inbox type (`invited`, `event_changed`, `event_cancelled`,
  `event_uncancelled`, `cohost_added`, `waitlist_promoted`, `wall_post`,
  `rsvp`). A type the app doesn't know is shown as sent and has no
  buttons.
- `actorId`, `actorName`: who caused it, for the sender's name and photo
  (communication notifications). Omit for `waitlist_promoted`, which has
  no actor.

## Other types

The same shape without `category`, worded like the inbox:

| `type` | `alert.title` | `alert.body` |
|---|---|---|
| `event_changed` | the event | "Ana L changed the time and place" |
| `event_cancelled` | the event | "Ana L cancelled it" |
| `event_uncancelled` | the event | "It's back on" |
| `cohost_added` | the creator | "Made you a co-host of Rooftop dinner" |
| `waitlist_promoted` | the event | "You got a spot! You're going" |
| `wall_post` | the host | "Posted on Rooftop dinner: …" (the first 200 characters) |
| `rsvp` | the event | "Ben O and 3 others answered" |
