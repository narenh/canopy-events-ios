import SwiftUI

/// An event's cover, filling whatever frame it's given (aspect fill,
/// cropped), at the size that frame needs (`CoverSize`). Without a cover,
/// or while it loads or if it can't, the generated `CoverArt`.
struct CoverPicture: View {
    let eventId: String
    let images: [CoverImage]
    let fullSizeUrl: URL?
    var theme: EventTheme = .canopyGreen

    @Environment(\.displayScale) private var scale
    /// The widest the frame has been: a bigger frame takes a bigger file,
    /// a smaller one keeps what it has.
    @State private var width: CGFloat = 0

    var body: some View {
        // Color.clear takes the frame the caller gives; the image fills it
        // and is clipped, so a wide photo never widens the layout.
        Color.clear
            .overlay {
                if let url {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            CoverArt(eventId: eventId, theme: theme)
                        }
                    }
                } else {
                    CoverArt(eventId: eventId, theme: theme)
                }
            }
            .clipped()
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = max(width, $0) }
    }

    private var url: URL? {
        guard width > 0 else { return nil }
        return CoverSize.url(in: images, fallback: fullSizeUrl, frameWidth: width, scale: scale)
    }
}

extension CoverPicture {
    /// The event's own cover and colors.
    init(event: Event) {
        self.init(eventId: event.id, images: event.coverImages, fullSizeUrl: event.coverImageUrl, theme: event.theme)
    }
}

#Preview {
    VStack {
        CoverPicture(event: PreviewData.event()).aspectRatio(3 / 2, contentMode: .fit)
        CoverPicture(event: PreviewData.event(MockEvents.gameNightId)).aspectRatio(3 / 2, contentMode: .fit)
    }
}
