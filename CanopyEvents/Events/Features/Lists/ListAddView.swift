import SwiftUI

/// "Add to Drag Race": a list's "Add people", pushed inside its sheet.
/// The shared picker, with everyone on the list greyed "On list" and your
/// other lists' "Add all <n>", and "Add 5" in the tray. Back returns to
/// the list; adding returns there too, with what happened.
struct ListAddView: View {
    let listName: String
    @Bindable var model: PeoplePickerModel
    /// Called with the words to show ("Added 5 people. Invited them to 1 event.").
    let onAdded: (String) -> Void

    @Environment(\.eventsRepository) private var repository

    var body: some View {
        PeoplePickerList(model: model)
            .navigationTitle("Add to \(listName)")
            .inlineNavigationTitle()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                PickerTray(kind: .list, people: model.picker.tray, isSending: model.isSending,
                           onUnpick: { model.picker.setPicked([$0.id], false) }, onSend: add)
                    .background(.bar)
            }
    }

    private func add() {
        Task {
            if let words = await model.addToList(using: repository) { onAdded(words) }
        }
    }
}

#Preview {
    NavigationStack {
        ListAddView(listName: "Climbing",
                    model: PeoplePickerModel(target: .list(PreviewData.ownedList(MockLists.climbingId)), me: MockPeople.maya.id)) { _ in }
    }
    .mockEnvironment()
}
