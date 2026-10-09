import SwiftUI

/// A small outlined tag in capitals on plain glass (the web's `tag off`):
/// "On list", "All invited", and the status badges with no color (Can't
/// Go, Removed).
struct PlainTag: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(Typography.tag)
            .tracking(0.4)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .foregroundStyle(.white)
            .background(.white.opacity(0.10), in: .rect(cornerRadius: 8))
            .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(.white.opacity(0.55), lineWidth: 1) }
            .accessibilityLabel(title)
    }
}

#Preview {
    VStack {
        PlainTag(title: "On list")
        PlainTag(title: "All invited")
    }
    .padding()
    .canopyScreen()
}
