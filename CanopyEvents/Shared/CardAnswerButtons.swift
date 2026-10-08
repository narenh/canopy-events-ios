import SwiftUI

/// Going / Can't Go on the expanded notification, styled like the app's
/// answer buttons; once answered, what was said, with a checkmark.
struct CardAnswerButtons: View {
    /// The answer given, once one is (`GOING` / `NOT_GOING`).
    let answered: String?
    let onAnswer: (String) -> Void

    var body: some View {
        if let answered {
            Label(answered == "GOING" ? "You're going" : "You can't go", systemImage: "checkmark.circle.fill")
                .font(Typography.button)
                .foregroundStyle(Palette.accent)
                .frame(maxWidth: .infinity, minHeight: 50)
                .transition(.opacity)
        } else {
            HStack(spacing: Spacing.small) {
                Button { onAnswer("GOING") } label: {
                    Label("Going", systemImage: "checkmark.circle.fill").frame(maxWidth: .infinity)
                }
                .glassProminentButtonStyle()
                Button { onAnswer("NOT_GOING") } label: {
                    Label("Can't Go", systemImage: "xmark.circle").frame(maxWidth: .infinity)
                }
                .glassButtonStyle()
            }
            .font(Typography.button)
            .controlSize(.large)
            .tint(Palette.accent)
        }
    }
}
