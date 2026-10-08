import Foundation

/// Uploading and removing an event's cover.
extension MockEventsRepository {
    /// Mock: the photo is kept in a temporary file (one size, its own),
    /// and its colour worked out the way the server does. The theme
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
