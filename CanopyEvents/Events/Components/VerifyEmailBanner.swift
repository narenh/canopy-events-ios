import SwiftUI

/// The verify-your-email banner for quick (unverified) accounts. It has
/// no close button on purpose: it stays until the email is verified.
/// It never blocks anything. Screens get it with `.verifyEmailBanner()`.
struct VerifyEmailBanner: View {
    let email: String?
    @State private var isVerifying = false

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Image(systemName: "envelope.badge")
                .font(.title3)
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text("Verify your email")
                    .font(.subheadline.weight(.semibold))
                Text("Confirm \(email ?? "your email") to host events and keep your account.")
                    .font(.caption)
                    .foregroundStyle(Palette.muted)
            }
            Spacer(minLength: 0)
            Button("Verify") { isVerifying = true }
                .glassProminentButtonStyle()
                .controlSize(.small)
        }
        .padding(Spacing.medium)
        .glassSurface(cornerRadius: Radius.medium, tint: Palette.glow.opacity(0.6))
        .padding(.horizontal, Spacing.large)
        .padding(.bottom, Spacing.small)
        .sheet(isPresented: $isVerifying) {
            VerifyEmailSheet()
        }
    }
}

#Preview {
    VStack {
        VerifyEmailBanner(email: "sam@example.com")
        Spacer()
    }
    .canopyScreen()
    .mockEnvironment(signedInAs: MockPeople.sam)
}
