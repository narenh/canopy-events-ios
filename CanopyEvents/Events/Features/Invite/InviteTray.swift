import SwiftUI

/// The foot of the invite sheet: the picked, newest first, as a row of
/// faces (each one unpicks them), and the button, "Invite 7" ("Invite",
/// and off, at 0).
struct InviteTray: View {
    /// Newest first.
    let people: [Person]
    var isSending = false
    let onUnpick: (Person) -> Void
    let onSend: () -> Void

    @ScaledMetric(relativeTo: .body) private var face: CGFloat = 36

    var body: some View {
        HStack(spacing: Spacing.medium) {
            ScrollView(.horizontal) {
                HStack(spacing: Spacing.xSmall) {
                    ForEach(people) { person in
                        Button { onUnpick(person) } label: {
                            Avatar(person: person, size: face)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Take \(person.fullName) out")
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.vertical, Spacing.xxSmall)
            }
            .scrollIndicators(.hidden)
            .frame(minHeight: face)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(people.count) picked")
            Button(action: onSend) {
                Text(people.isEmpty ? "Invite" : "Invite \(people.count)")
                    .font(Typography.button)
                    .lineLimit(1)
                    .padding(.horizontal, Spacing.small)
            }
            .accentProminentButtonStyle()
            .controlSize(.large)
            .disabled(people.isEmpty || isSending)
            .layoutPriority(1)
        }
        .animation(.snappy, value: people.map(\.id))
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.small)
        .background(.bar)
    }
}

#Preview {
    VStack {
        Spacer()
        InviteTray(people: [MockPeople.ana, MockPeople.theo, MockPeople.ines, MockPeople.ben], onUnpick: { _ in }, onSend: {})
        InviteTray(people: [], onUnpick: { _ in }, onSend: {})
    }
    .canopyScreen()
}
