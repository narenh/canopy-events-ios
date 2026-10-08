import SwiftUI

/// The "When" part of the event form. Dates are picked in the event's
/// own time zone, so 7 PM means 7 PM where the event is.
struct EventEditorWhenSection: View {
    @Bindable var model: EventEditorModel

    private var eventTimeZone: TimeZone {
        TimeZone(identifier: model.draft.timeZone) ?? .current
    }

    var body: some View {
        Section("When") {
            DatePicker("Starts", selection: $model.draft.startsAt)
            Toggle("End time", isOn: $model.hasEndTime)
            if let endsAt = model.draft.endsAt {
                DatePicker(
                    "Ends",
                    selection: Binding(get: { endsAt }, set: { model.draft.endsAt = $0 }),
                    in: model.draft.startsAt...
                )
            }
            TimeZonePicker(identifier: $model.draft.timeZone)
        }
        .environment(\.timeZone, eventTimeZone)
    }
}

#Preview {
    Form { EventEditorWhenSection(model: EventEditorModel(event: nil)) }
        .preferredColorScheme(.dark)
}
