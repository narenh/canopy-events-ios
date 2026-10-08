import SwiftUI
import UserNotifications

/// The event's cover as a notification attachment: a local copy (the
/// system moves it into its own store), the 800 px size when there is
/// one, or the generated art drawn in the event's colours when there's no
/// cover (or it won't load). How iOS combines it with the communication
/// notification's avatar has to be checked on a phone (ARCHITECTURE.md).
enum NotificationCoverAttachment {
    static func make(for event: EventSummary) async -> UNNotificationAttachment? {
        let file: URL?
        if let url = CoverSize.url(in: event.coverImages, fallback: event.coverImageUrl, frameWidth: 400, scale: 2),
           let (data, response) = try? await URLSession.shared.data(from: url),
           (response as? HTTPURLResponse)?.statusCode ?? 200 == 200, !data.isEmpty {
            file = save(data, extension: "jpg")
        } else {
            file = art(for: event).flatMap { save($0, extension: "png") }
        }
        guard let file else { return nil }
        return try? UNNotificationAttachment(identifier: "cover", url: file, options: nil)
    }

    /// The generated cover, 600 × 400.
    private static func art(for event: EventSummary) -> Data? {
        let renderer = ImageRenderer(content:
            CoverArt(eventId: event.id, theme: EventTheme(hue: event.themeHue, grayscale: event.themeGrayscale))
                .frame(width: 600, height: 400)
        )
        renderer.scale = 1
        return renderer.cgImage?.pngData
    }

    private static func save(_ data: Data, extension ext: String) -> URL? {
        let url = URL.temporaryDirectory.appending(path: "notification-cover-\(UUID().uuidString).\(ext)")
        return (try? data.write(to: url)) != nil ? url : nil
    }
}
