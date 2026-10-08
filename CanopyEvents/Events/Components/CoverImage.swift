import SwiftUI

/// An event's cover image, filling whatever frame it's given. Without a
/// cover (or while loading) it shows a green gradient.
struct CoverImage: View {
    let url: URL?

    var body: some View {
        // Color.clear takes the frame the caller gives; the image fills it
        // and is clipped, so a wide photo never widens the layout.
        Color.clear
            .overlay {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    placeholder
                }
            }
            .clipped()
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [Palette.glowBright, Palette.glowDeep],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "leaf")
                .font(.title)
                .foregroundStyle(.white.opacity(0.2))
        }
    }
}

#Preview {
    VStack {
        CoverImage(url: PreviewData.event().coverImageUrl).frame(height: 200)
        CoverImage(url: nil).frame(height: 200)
    }
}
