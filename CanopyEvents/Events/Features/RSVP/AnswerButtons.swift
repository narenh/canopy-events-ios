import SwiftUI

/// Going / Maybe / Can't go as three glass buttons, with your current
/// answer filled in. Used on invite rows and the event page.
struct AnswerButtons: View {
    /// Your answer now, if any. Its button is drawn prominent.
    let current: RSVPStatus?
    var isDisabled = false
    let onAnswer: (RSVPStatus) -> Void

    var body: some View {
        HStack(spacing: Spacing.small) {
            ForEach(RSVPStatus.answers, id: \.self) { status in
                button(for: status)
            }
        }
        .disabled(isDisabled)
    }

    @ViewBuilder private func button(for status: RSVPStatus) -> some View {
        let isCurrent = status == current || (status == .going && current == .waitlisted)
        let button = Button {
            onAnswer(status)
        } label: {
            // Words only, like the web: they fit three across at large sizes.
            Text(status.title)
                .font(.body.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
        }
        if isCurrent {
            button.glassProminentButtonStyle()
        } else {
            button.glassButtonStyle()
        }
    }
}

#Preview {
    VStack(spacing: Spacing.large) {
        AnswerButtons(current: nil) { _ in }
        AnswerButtons(current: .going) { _ in }
        AnswerButtons(current: .notGoing) { _ in }
    }
    .padding()
    .canopyScreen()
    .preferredColorScheme(.dark)
}
