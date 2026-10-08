import SwiftUI

/// TMDB's logo and credit, required wherever the backgrounds show.
struct TMDBCredit: View {
    var body: some View {
        HStack(alignment: .center, spacing: Spacing.medium) {
            Image("TMDBLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 72)
                .accessibilityLabel("TMDB")
            Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TMDBCredit().padding().preferredColorScheme(.dark)
}
