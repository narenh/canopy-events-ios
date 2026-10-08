import SwiftUI

extension View {
    /// Pins the verify-your-email banner to the top of this screen while
    /// the signed-in account is unverified. Apply to a screen inside its
    /// NavigationStack, so the banner sits under the navigation bar.
    func verifyEmailBanner() -> some View {
        modifier(VerifyEmailBannerInset())
    }
}

/// Reads the session and insets the banner at the top. Used by
/// `verifyEmailBanner()`.
private struct VerifyEmailBannerInset: ViewModifier {
    @Environment(AppSession.self) private var session

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .top, spacing: 0) {
            if session.needsVerification {
                VerifyEmailBanner(email: session.profile?.email)
            }
        }
    }
}
