import SwiftUI

/// The app's name and tagline on the sign-in screen. A placeholder until
/// there's a real logo asset.
struct CanopyWordmark: View {
    var body: some View {
        VStack(spacing: Spacing.small) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
            Text("Canopy Events")
                .font(Typography.heroTitle)
            Text("Plans with your people.")
                .foregroundStyle(Palette.muted)
        }
    }
}

#Preview {
    CanopyWordmark()
        .canopyScreen()
        .preferredColorScheme(.dark)
}
