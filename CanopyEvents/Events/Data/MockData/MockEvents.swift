import Foundation

/// The mock world's events, as server-side records. A mix on purpose:
/// hosted, co-hosted, invited, waitlisted, full, cancelled, hidden guest
/// lists, another time zone, and past events (which make friends).
enum MockEvents {
    /// Every record, upcoming and past, with the lists on them.
    static var all: [MockEventRecord] {
        (upcoming + withLists + past).map { record in
            var record = record
            record.attachedLists += listsOnEvents[record.id, default: []]
            return record
        }
    }

    // MARK: Building blocks

    static let pacific = "America/Los_Angeles"

    /// An event with sensible defaults; per-viewer fields are left empty
    /// for `MockRules` to fill in.
    static func event(
        id: String, title: String, description: String? = nil,
        days: Int, hour: Int, minute: Int = 0, hours: Double? = 3,
        timeZone: String = pacific, locationName: String?, locationAddress: String?, pin: MockPin? = nil,
        visibility: GuestListVisibility = .everyone, hosts: [Host],
        capacity: Int? = nil, guestsAllowed: Int = 0, cover: MockCover? = nil, theme: EventTheme = .canopyGreen,
        accentHue: Int? = nil, details: [EventDetail] = [], cancelled: Bool = false
    ) -> Event {
        let color = theme.apiFields()
        let start = MockDate.at(days: days, hour: hour, minute: minute, timeZone: timeZone)
        let created = start.addingTimeInterval(-14 * 24 * 60 * 60)
        return Event(
            id: id,
            url: URL(string: "https://events.canopysf.com/e/\(id)")!,
            title: title, description: description,
            startsAt: start, endsAt: hours.map { start.addingTimeInterval($0 * 60 * 60) },
            timeZone: timeZone, locationName: locationName, locationAddress: locationAddress,
            latitude: pin?.latitude, longitude: pin?.longitude, applePlaceId: pin?.applePlaceId,
            locationAddressHidden: false, details: details, hiddenDetails: 0, guestListVisibility: visibility,
            guestsAllowed: guestsAllowed, capacity: capacity, spotsLeft: nil,
            coverImageUrl: cover?.images.last?.url, coverImages: cover?.images ?? [],
            themeHue: color.themeHue, themeGrayscale: color.themeGrayscale,
            accentHue: color.themeGrayscale ? accentHue : nil,
            coverHue: cover?.hue, coverGrayscale: cover?.isGrey ?? false,
            status: cancelled ? .cancelled : .active,
            cancelledAt: cancelled ? MockDate.ago(minutes: 300) : nil,
            createdAt: created, updatedAt: created,
            hosts: hosts, counts: RSVPCounts(), viewer: nil, friendsGoing: nil
        )
    }

    /// A sample cover: picsum.photos placeholders at the API's sizes (the
    /// generated art shows offline), with the color said to match it.
    static func cover(_ seed: String, hue: Int?) -> MockCover {
        MockCover(
            images: [400, 800, 1200, 1600].map { width in
                let height = width * 2 / 3
                return CoverImage(
                    width: width, height: height,
                    url: URL(string: "https://picsum.photos/seed/canopy-\(seed)/\(width)/\(height)")!
                )
            },
            hue: hue
        )
    }

    static func host(_ person: Person) -> Host { Host(person: person, role: .creator) }
    static func cohost(_ person: Person) -> Host { Host(person: person, role: .cohost) }

    /// A guest-list entry. `invited` entries have no answer time.
    static func guest(_ person: Person, _ status: RSVPStatus, plus: Int = 0) -> Guest {
        Guest(
            person: person, status: status, guests: plus, guestsOverLimit: false,
            respondedAt: status == .invited ? nil : MockDate.ago(minutes: 60 * 24 * 2)
        )
    }
}
