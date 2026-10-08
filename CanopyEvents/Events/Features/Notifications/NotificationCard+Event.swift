import Foundation

extension NotificationCard {
    /// The card for an event as you see it, with the first page of its
    /// guest list for the faces (friends first, as Attending orders them).
    init(event: Event, guests: [Guest]) {
        let people = Attending.people(friends: event.friendsGoing?.people ?? [], guests: guests)
        self.init(
            eventId: event.id, title: event.title, startsAt: event.startsAt, endsAt: event.endsAt,
            timeZone: event.timeZone, locationName: event.locationName,
            coverUrl: CoverSize.url(in: event.coverImages, fallback: event.coverImageUrl, frameWidth: 400, scale: 2),
            themeHue: event.themeHue, themeGrayscale: event.themeGrayscale,
            going: event.counts.going, maybe: event.counts.maybe,
            faces: people.prefix(6).map { CardFace(name: $0.fullName, photoUrl: $0.photoUrl) }
        )
    }

    /// The card for one event, fetched through the repository.
    static func load(_ eventId: Event.ID, from repository: any EventsRepository) async throws -> NotificationCard {
        async let event = repository.event(id: eventId)
        async let guests = repository.guestList(eventId: eventId, status: nil, page: PageRequest(limit: 20))
        return NotificationCard(event: try await event, guests: try await guests.guests)
    }
}
