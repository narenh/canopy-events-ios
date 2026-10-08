import Foundation
import SwiftUI

/// A person's picture as PNG data, for a notification's sender: their
/// photo when they have one (and it loads), else their initials in a
/// circle, drawn like `Avatar`.
enum AvatarImage {
    static func pngData(for person: Person) async -> Data? {
        if let url = person.photoUrl,
           let (data, response) = try? await URLSession.shared.data(from: url),
           (response as? HTTPURLResponse)?.statusCode == 200, !data.isEmpty {
            return data
        }
        return initials(for: person)
    }

    /// The initials, white on Canopy's brightest glow, 180 px square.
    static func initials(for person: Person) -> Data? {
        let renderer = ImageRenderer(content:
            Text(person.initials)
                .font(.system(size: 72, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 180, height: 180)
                .background(Palette.glowBright, in: .circle)
        )
        renderer.scale = 1
        return renderer.cgImage?.pngData
    }
}
