import SwiftUI

/// A small colored capsule like "Hosting" or "Cancelled".
struct TagLabel: View {
    let title: String
    var systemImage: String?
    var tint: Color = .accentColor

    var body: some View {
        Label {
            Text(title)
        } icon: {
            if let systemImage { Image(systemName: systemImage) }
        }
        .labelStyle(.titleAndIcon)
        .font(.footnote.weight(.bold))
        .foregroundStyle(tint)
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xSmall)
        .background(tint.opacity(0.18), in: .capsule)
    }
}

#Preview {
    VStack {
        TagLabel(title: "Hosting", systemImage: "star.fill")
        TagLabel(title: "Cancelled", systemImage: "xmark.octagon", tint: Palette.danger)
    }
    .padding()
    .preferredColorScheme(.dark)
}
