import SwiftUI

/// A list's sheet under its title: the link with Share, Copy and QR (out
/// of the way while searching), a line after something was done, then its
/// people with Add people and the name search.
struct ListSheetList: View {
    let list: OwnedList
    @Bindable var model: OwnListModel
    @Binding var showsQR: Bool
    let onAdd: () -> Void
    let onRemove: (ListMember) -> Void

    var body: some View {
        List {
            if !model.isSearching {
                Section {
                    ListSheetHeader(list: list, showsQR: $showsQR) { model.notice = "Link copied." }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            if let notice = model.notice {
                Text(notice)
                    .foregroundStyle(Palette.link)
                    .listRowBackground(Color.clear)
            }
            ListMembersSection(list: list, members: model.shownMembers, isSearching: model.isSearching,
                               onAdd: onAdd, onRemove: onRemove)
        }
        .glassList()
        .alwaysShownSearch(text: $model.query, prompt: "Search by name")
    }
}

#Preview {
    @Previewable @State var showsQR = false
    let model = OwnListModel(listId: MockLists.climbingId)
    NavigationStack {
        ListSheetList(list: PreviewData.ownedList(MockLists.climbingId), model: model, showsQR: $showsQR,
                      onAdd: {}, onRemove: { _ in })
            .task { await model.load(from: MockEventsRepository(delay: .zero)) }
    }
    .mockEnvironment()
}
