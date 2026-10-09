import Foundation

/// What a copy of an event starts with (the API's `DuplicateDraft`, from
/// `GET /events/{id}/duplicate-draft`): `EventInput`'s fields except the
/// times, plus the original's cover to show and your own lists that were
/// on it. Copied: the title, description, place, zone, every detail, guest
/// list visibility, plus-ones, capacity, color and the cover (`coverFrom`).
/// Not copied: the date and times, guests, invitations and answers,
/// co-hosts, the wall and lists. Nothing is made until the host saves.
nonisolated struct DuplicateDraft: Codable, Hashable {
    var title: String
    var description: String?
    var timeZone: String
    var locationName: String?
    var locationAddress: String?
    /// Every detail, the hidden-when-signed-out ones too: ready to send back.
    var details: [EventDetailInput]
    var guestListVisibility: GuestListVisibility
    var guestsAllowed: Int
    var capacity: Int?
    var themeHue: Int?
    var themeGrayscale: Bool
    var accentHue: Int?
    /// The original's id when it has a cover: send it as `coverFrom` and
    /// the new event gets its own copy. Nil when it has none.
    var coverFrom: String?
    /// The original's cover, only to show in the editor.
    var coverImageUrl: URL?
    var coverImages: [CoverImage]
    /// The cover's matching hue and grey flag, for Match photo.
    var coverHue: Int?
    var coverGrayscale: Bool
    /// Your own lists that were on the original: not attached to the copy,
    /// offered once it's made (attaching one invites everyone on it).
    var lists: [DuplicateDraftList]
}

nonisolated extension DuplicateDraft {
    /// The color that matches the original's cover, or nil when it isn't known.
    var coverTheme: EventTheme? {
        if coverGrayscale { return .grayscale }
        return coverHue.map { .hue($0) }
    }
}
