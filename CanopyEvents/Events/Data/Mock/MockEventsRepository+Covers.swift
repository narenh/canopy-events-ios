import Foundation

/// Uploading and removing an event's cover.
extension MockEventsRepository {
    /// Mock: the photo is kept in a temporary file (one size, its own),
    /// and its color worked out the way the server does. The theme
    /// doesn't change: that's the host's call.
    func setCover(eventId: Event.ID, imageData: Data) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        guard imageData.count <= 15_000_000 else { throw APIError(message: "Covers are up to 15 MB.", reason: .tooLarge) }
        guard let size = MockCoverFile.pixelSize(of: imageData), let url = MockCoverFile.save(imageData) else {
            throw APIError(message: "That isn't an image.", reason: .badImage)
        }
        let match = PhotoHue.theme(ofImageData: imageData)
        record.event.coverImageUrl = url
        record.event.coverImages = [CoverImage(width: size.width, height: size.height, url: url)]
        record.event.coverHue = if case .hue(let hue) = match { hue } else { nil }
        record.event.coverGrayscale = match == .grayscale
        save(record)
        return resolved(record)
    }

    func deleteCover(eventId: Event.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        record.event.coverImageUrl = nil
        record.event.coverImages = []
        record.event.coverHue = nil
        record.event.coverGrayscale = false
        save(record)
        return resolved(record)
    }
}

/// The TMDB backgrounds: choosing one makes it the cover, as an upload.
extension MockEventsRepository {
    func backgrounds() async throws -> BackgroundList {
        await pause()
        return BackgroundList(enabled: true, backgrounds: MockBackgrounds.all)
    }

    /// Mock: the cover is TMDB's own sizes (the real server stores a copy).
    func setCoverBackground(eventId: Event.ID, backgroundId: Background.ID) async throws -> Event {
        await pause()
        var record = try record(eventId)
        guard record.isHost(currentUser.id) else { throw APIError.hostsOnly }
        guard let background = MockBackgrounds.all.first(where: { $0.id == backgroundId }) else {
            throw APIError(message: "That background isn't available any more.", reason: .badBackground)
        }
        let original = URL(string: background.previewUrl.absoluteString.replacingOccurrences(of: "/w780/", with: "/original/"))!
        record.event.coverImages = [
            CoverImage(width: 400, height: 225, url: background.thumbUrl),
            CoverImage(width: 800, height: 450, url: background.previewUrl),
            CoverImage(width: 1600, height: 900, url: original),
        ]
        record.event.coverImageUrl = original
        record.event.coverHue = background.hue
        record.event.coverGrayscale = background.grayscale
        save(record)
        return resolved(record)
    }
}
