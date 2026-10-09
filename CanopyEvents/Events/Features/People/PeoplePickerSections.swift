import SwiftUI

/// A picker's people: who a lookup found, then your lists and Suggested
/// (not while searching or filtered), then everyone (or the matches, or
/// the past event's people), or a quiet line saying why there's no one.
struct PeoplePickerSections: View {
    let model: PeoplePickerModel

    private var picker: PeoplePicker { model.picker }

    var body: some View {
        if let lookup = model.lookup, lookup.query == picker.query.trimmingCharacters(in: .whitespaces) {
            Section("Found") { found(lookup.state) }
                .glassRowBackground()
        }
        if let from = picker.from, from.isHidden {
            quiet(PeoplePicker.hidden(from.title))
        } else {
            people
        }
    }

    @ViewBuilder private var people: some View {
        let order = picker.order
        if !picker.isSearching, picker.from == nil {
            let lists = picker.lists.filter { !$0.memberIds.isEmpty }
            if !lists.isEmpty {
                Section("Your lists") {
                    ForEach(lists) { list in
                        PickerListRow(kind: picker.kind, list: list, pickable: picker.pickable(in: list).count,
                                      isAllPicked: picker.isAllPicked(list)) { model.picker.toggleAll(in: list) }
                    }
                }
                .glassRowBackground()
            }
            if !order.suggested.isEmpty {
                Section("Suggested") { rows(order.suggested) }
                    .glassRowBackground()
            }
        }
        if !order.everyone.isEmpty {
            Section(heading(suggested: !order.suggested.isEmpty)) { rows(order.everyone) }
                .glassRowBackground()
        } else if model.hasLoaded, picker.isSearching, LookupKind(picker.query) == nil {
            quiet("No one by that name. Type a whole phone number or @username to find someone.")
        } else if let from = picker.from, !picker.isSearching {
            quiet(PeoplePicker.empty(from.title))
        } else if model.hasLoaded, !picker.isSearching, order.suggested.isEmpty {
            quiet("No friends here yet. Type a phone number or @username to find someone, or share the link.")
        }
    }

    private func heading(suggested: Bool) -> String {
        if picker.isSearching { return "Matches" }
        if let from = picker.from { return "From \(from.title)" }
        return suggested ? "Everyone else" : "Everyone"
    }

    private func rows(_ ids: [Person.ID]) -> some View {
        ForEach(ids, id: \.self) { id in
            if let candidate = picker.people[id] {
                PickerPersonRow(candidate: candidate, status: picker.taken[id],
                                isPicked: picker.isPicked(id)) { model.picker.toggle(id) }
            }
        }
    }

    @ViewBuilder private func found(_ state: PickerLookup.State) -> some View {
        switch state {
        case .looking:
            Text("Looking…").foregroundStyle(Palette.muted)
        case .found(let id):
            rows([id])
        case .none:
            Text("No one found. Check the number or username, or share the link with them instead.")
                .foregroundStyle(Palette.muted)
        case .failed(let words):
            Text(words).foregroundStyle(Palette.danger)
        }
    }

    private func quiet(_ words: String) -> some View {
        Text(words)
            .foregroundStyle(Palette.muted)
            .listRowBackground(Color.clear)
    }
}

#Preview {
    let model = PeoplePickerModel(target: .list(PreviewData.ownedList(MockLists.climbingId)), me: MockPeople.maya.id)
    List { PeoplePickerSections(model: model) }
        .task { await model.load(from: MockEventsRepository(delay: .zero)) }
        .canopyScreen()
}
