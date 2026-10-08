import SwiftUI

/// Profile's events settings, in the form: the calendar toggle ("Show
/// events I'm invited to", on by default) and, when there are any, the
/// hosts whose invitations you've opted out of, each with Undo.
struct ProfileSettingsSections: View {
    @Environment(\.eventsRepository) private var repository
    @State private var model = ProfileSettingsModel()

    var body: some View {
        Section("Calendar") {
            Toggle("Show events I'm invited to", isOn: Binding(
                get: { model.calendarInvites },
                set: { on in Task { await model.setCalendarInvites(on, using: repository) } }
            ))
            .disabled(!model.hasLoaded)
        }
        .glassRowBackground()
        .task { await model.load(from: repository) }
        .errorAlert($model.errorMessage)

        if !model.optedOut.isEmpty {
            Section("Not taking invites from") {
                ForEach(model.optedOut) { host in
                    PersonRow(person: host) {
                        Button("Undo") { Task { await model.allowInvites(from: host, using: repository) } }
                            .buttonStyle(.borderless)
                    }
                }
            }
            .glassRowBackground()
        }
    }
}
