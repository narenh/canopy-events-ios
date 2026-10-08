import SwiftUI

/// Your answer as a small pill that opens a menu to answer again
/// ("Can't Go ▾": Can't Go, the current one, then Going and Maybe), where
/// the status badge would be. For declined events, so changing your mind
/// is quiet, not a big button.
struct AnswerMenuPill: View {
    let current: RSVPStatus
    let onAnswer: (RSVPStatus) -> Void

    var body: some View {
        Menu {
            ForEach([current] + RSVPStatus.answers.filter { $0 != current }, id: \.self) { status in
                Button {
                    if status != current { onAnswer(status) }
                } label: {
                    if status == current {
                        Label(status.title, systemImage: "checkmark")
                    } else {
                        Text(status.title)
                    }
                }
            }
        } label: {
            HStack(spacing: Spacing.xSmall) {
                Text(current.title.uppercased())
                Image(systemName: "chevron.down").font(.caption2.weight(.bold))
            }
            .font(Typography.tag)
            .tracking(0.4)
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(.white.opacity(0.10), in: .rect(cornerRadius: 8))
            .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(.white.opacity(0.55), lineWidth: 1) }
            .contentShape(.rect)
        }
        .accessibilityLabel("Your answer: \(current.title). Change it")
    }
}

#Preview {
    AnswerMenuPill(current: .notGoing) { _ in }
        .padding()
        .canopyScreen()
}
