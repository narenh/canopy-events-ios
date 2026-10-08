import SwiftUI

/// The "canopy events" lockup and the app's tagline on the sign-in
/// screen.
struct CanopyWordmark: View {
    var body: some View {
        VStack(spacing: Spacing.large) {
            Image(.eventsHero)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300)
                .accessibilityLabel("Canopy Events")
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
