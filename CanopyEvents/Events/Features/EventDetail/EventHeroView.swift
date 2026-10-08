import SwiftUI

/// The top of the event page: the cover image with the title over it.
struct EventHeroView: View {
    let event: Event

    var body: some View {
        CoverImage(url: event.coverImageUrl)
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .overlay {
                // Darkens the bottom so the title reads on any photo.
                LinearGradient(colors: [.clear, Palette.base.opacity(0.85)], startPoint: .center, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    if event.isCancelled {
                        TagLabel(title: "Cancelled", systemImage: "xmark.octagon", tint: Palette.danger)
                    }
                    Text(event.title)
                        .font(Typography.heroTitle)
                        .foregroundStyle(.white)
                        .shadow(radius: 8)
                }
                .padding(Spacing.large)
            }
    }
}

#Preview {
    VStack {
        EventHeroView(event: PreviewData.event(MockEvents.rooftopId))
        EventHeroView(event: PreviewData.event(MockEvents.karaokeId))
    }
    .preferredColorScheme(.dark)
}
