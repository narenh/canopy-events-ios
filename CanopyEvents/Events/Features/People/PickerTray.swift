import SwiftUI

/// The foot of a picker: the picked, newest first, as a row of faces
/// (each one unpicks them), and the button, "Invite 7" or "Add 7" (just
/// "Invite" / "Add", and off, at 0). An invitation's tray can also have a
/// quiet "Save as list" beside it. The sheet draws the bar behind it.
struct PickerTray: View {
    let kind: PeoplePicker.Kind
    /// Newest first.
    let people: [Person]
    var isSending = false
    let onUnpick: (Person) -> Void
    let onSend: () -> Void
    /// "Save as list"; nil hides it.
    var onSaveAsList: (() -> Void)?

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
            if let onSaveAsList {
                Button("Save as list", action: onSaveAsList)
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.borderless)
                    .lineLimit(1)
                    .disabled(people.isEmpty || isSending)
                    .layoutPriority(1)
            }
            Button(action: onSend) {
                Text(kind.send(people.count))
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
    }
}

#Preview {
    VStack {
        Spacer()
        PickerTray(kind: .invite, people: [MockPeople.ana, MockPeople.theo, MockPeople.ines, MockPeople.ben],
                   onUnpick: { _ in }, onSend: {}, onSaveAsList: {})
        PickerTray(kind: .invite, people: [], onUnpick: { _ in }, onSend: {}, onSaveAsList: {})
        PickerTray(kind: .list, people: [MockPeople.ana, MockPeople.theo], onUnpick: { _ in }, onSend: {})
    }
    .background(.bar)
    .canopyScreen()
}
