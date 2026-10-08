import Foundation

/// What the expanded invite notification draws, carried in the push
/// itself (`userInfo["card"]`, docs/push-payloads.md), since the
/// extension can't reach the app's data: the event's title, when, place,
/// cover and colour, and a few of the faces going.
nonisolated struct NotificationCard: Codable, Hashable, Identifiable, Sendable {
    var eventId: String
    var title: String
    var startsAt: Date
    var endsAt: Date?
    var timeZone: String
    var locationName: String?
    /// The cover at a size for a phone's width (the 800 px one).
    var coverUrl: URL?
    var themeHue: Int?
    var themeGrayscale: Bool
    var going: Int
    var maybe: Int
    /// Up to six, friends first.
    var faces: [CardFace]

    static let userInfoKey = "card"

    var id: String { eventId }

    var theme: EventTheme { EventTheme(hue: themeHue, grayscale: themeGrayscale) }
    var zone: TimeZone { TimeZone(identifier: timeZone) ?? .current }

    /// From a notification's `userInfo`, or nil without a card.
    init?(userInfo: [AnyHashable: Any]) {
        guard let object = userInfo[Self.userInfoKey], JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object),
              let card = try? JSONDecoder.eventsAPI.decode(Self.self, from: data)
        else { return nil }
        self = card
    }

    init(eventId: String, title: String, startsAt: Date, endsAt: Date?, timeZone: String, locationName: String?,
         coverUrl: URL?, themeHue: Int?, themeGrayscale: Bool, going: Int, maybe: Int, faces: [CardFace]) {
        self.eventId = eventId
        self.title = title
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.timeZone = timeZone
        self.locationName = locationName
        self.coverUrl = coverUrl
        self.themeHue = themeHue
        self.themeGrayscale = themeGrayscale
        self.going = going
        self.maybe = maybe
        self.faces = faces
    }

    /// The card as a `userInfo` value (plain JSON types).
    var userInfoValue: Any? {
        guard let data = try? JSONEncoder.eventsAPI.encode(self) else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }
}
