import SwiftUI

/// The "write a post" bar pinned to the bottom of the wall.
struct WallComposer: View {
    @Binding var text: String
    let canPost: Bool
    let onPost: () -> Void

    var body: some View {
        HStack(spacing: Spacing.small) {
            TextField("Write something…", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.small)
                .glassSurface(cornerRadius: Radius.medium)
            Button("Post", systemImage: "arrow.up", action: onPost)
                .labelStyle(.iconOnly)
                .accentProminentButtonStyle()
                .buttonBorderShape(.circle)
                .disabled(!canPost)
        }
        .padding(Spacing.medium)
    }
}

#Preview {
    @Previewable @State var text = ""
    VStack {
        Spacer()
        WallComposer(text: $text, canPost: !text.isEmpty) {}
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
