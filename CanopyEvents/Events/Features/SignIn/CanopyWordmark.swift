import SwiftUI

/// The Canopy logo and the app's tagline on the sign-in screen. The logo
/// is the same PNG the account service's pages use.
struct CanopyWordmark: View {
    var body: some View {
        VStack(spacing: Spacing.medium) {
            Image(.canopyLogo)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220)
                .accessibilityLabel("Canopy")
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
