import SwiftUI

/// The guest rules part of the event form: capacity, plus-ones, and who
/// can see the guest list.
struct EventEditorGuestsSection: View {
    @Bindable var model: EventEditorModel

    var body: some View {
        Section {
            Toggle("Limit spots", isOn: $model.hasCapacity)
            if let capacity = model.draft.capacity {
                Stepper(
                    "\(capacity) spots",
                    value: Binding(get: { capacity }, set: { model.draft.capacity = $0 }),
                    in: 1...500
                )
            }
            Stepper(plusOnesTitle, value: $model.draft.plusOnesAllowed, in: 0...5)
        } header: {
            Text("Guests")
        } footer: {
            Text("Past the limit, people who say going join a waitlist. Plus-ones count toward it.")
        }

        Section {
            Picker("Who sees the guest list", selection: $model.draft.guestListVisibility) {
                ForEach(GuestListVisibility.allCases, id: \.self) { Text($0.title).tag($0) }
            }
        } footer: {
            Text(model.draft.guestListVisibility.explanation + " Everyone always sees the counts.")
        }
    }

    private var plusOnesTitle: String {
        switch model.draft.plusOnesAllowed {
        case 0: "No plus-ones"
        case 1: "1 plus-one each"
        default: "\(model.draft.plusOnesAllowed) plus-ones each"
        }
    }
}

#Preview {
    Form { EventEditorGuestsSection(model: EventEditorModel(event: nil)) }
        .preferredColorScheme(.dark)
}
