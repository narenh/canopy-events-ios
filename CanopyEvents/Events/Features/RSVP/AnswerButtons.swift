import SwiftUI

/// Going / Maybe / Can't Go as three glass buttons, with your current
/// answer filled in. Used on invite rows and the event page.
struct AnswerButtons: View {
    /// Your answer now, if any. Its button is drawn prominent.
    let current: RSVPStatus?
    /// Which to offer: all three on the event page; Going and Can't Go on
    /// an invitation card; just Going on a declined one.
    var answers = RSVPStatus.answers
    var isDisabled = false
    let onAnswer: (RSVPStatus) -> Void

    var body: some View {
        // Going takes half the row, Maybe and Can't Go a quarter each (the
        // web's widths): going is the answer to reach for.
        // With fewer than three, they share the row evenly.
        WeightedHStack(weights: answers.map { $0 == .going && answers.count == 3 ? 2 : 1 }, spacing: Spacing.small) {
            ForEach(answers, id: \.self) { status in
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
            button.accentProminentButtonStyle()
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
