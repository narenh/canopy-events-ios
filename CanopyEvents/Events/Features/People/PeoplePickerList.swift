import SwiftUI

/// The picker under a sheet's title, shared by the invite sheet and a
/// list's "Add people": one search field (names, and a whole phone number
/// or @username to look someone up), "Filter by past event" under it,
/// then your lists with "Invite all <n>" ("Add all <n>"), Suggested (the
/// first eight not there yet), and everyone else A to Z. Filtered, it's
/// just that event's people, and typing searches within them. People
/// there already stay in the list, greyed. The sheet adds its title and
/// its tray.
struct PeoplePickerList: View {
    @Bindable var model: PeoplePickerModel

    @Environment(\.eventsRepository) private var repository
    @Environment(AppSession.self) private var session

    var body: some View {
        List {
            if !model.pastEvents.isEmpty {
                Section {
                    PastEventFilterMenu(events: model.pastEvents, selection: fromSelection)
                }
                .glassRowBackground()
            }
            PeoplePickerSections(model: model)
        }
        .glassList()
        .overlay { if !model.hasLoaded { ProgressView() } }
        .alwaysShownSearch(text: $model.picker.query,
                           prompt: session.needsVerification ? "Search by name" : "Name, phone or @username")
        .task { if !model.hasLoaded { await model.load(from: repository) } }
        .task(id: model.picker.query) { await model.lookUp(using: repository) }
        .onChange(of: model.picker.selected.count) { _, count in
            AccessibilityNotification.Announcement("\(count) picked.").post()
        }
        .errorAlert($model.errorMessage)
    }

    /// The menu shows the choice at once; the list narrows once that
    /// event's people are in, and VoiceOver hears how many.
    private var fromSelection: Binding<Event.ID?> {
        Binding(get: { model.fromId }, set: { id in
            Task {
                if let words = await model.filter(by: id, using: repository) {
                    AccessibilityNotification.Announcement(words).post()
                }
            }
        })
    }
}

#Preview("Inviting to Board game night") {
    NavigationStack {
        PeoplePickerList(model: PeoplePickerModel(target: .event(PreviewData.event(MockEvents.gameNightId)), me: MockPeople.maya.id))
            .navigationTitle("Invite")
    }
    .mockEnvironment()
}
