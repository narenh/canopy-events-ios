import SwiftUI

/// What the expanded notification shows when it carries no card it can
/// read (an older or different payload): its own title and body on
/// Canopy's dark green, and the answer buttons when it names an event.
struct NotificationFallbackView: View {
    let title: String
    let message: String
    /// Nil when the notification names no event: nothing to answer.
    let answered: String?
    let canAnswer: Bool
    let onAnswer: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(title).font(Typography.cardHeading)
            Text(message).foregroundStyle(Palette.muted)
            if canAnswer {
                CardAnswerButtons(answered: answered, onAnswer: onAnswer)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.large)
        .background(Palette.base)
        .environment(\.colorScheme, .dark)
    }
}
