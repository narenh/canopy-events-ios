import SwiftUI

/// The guests sheet's list: a line after a host's change, then the tabs,
/// the chosen tab's count and plus-ones, and its people; or, while
/// searching, everyone whose name matches, each with their status.
struct GuestsList: View {
    @Bindable var model: GuestsModel
    let onRemove: (Guest) -> Void
    let onUndo: (Guest) -> Void

    var body: some View {
        List {
            if let notice = model.notice {
                Text(notice).foregroundStyle(Palette.link).listRowBackground(Color.clear)
            }
            if let tabs = model.tabs {
                if tabs.isSearching {
                    Section { rows(tabs.matches, showsStatus: true) }
                        .glassRowBackground()
                    if tabs.matches.isEmpty { quiet("No one by that name.") }
                } else if let shown = tabs.shown(model.chosen) {
                    Section {
                        GuestTabBar(tabs: tabs, shown: shown) { model.chosen = $0 }
                        quiet(tabs.summary(shown))
                        if shown == .removed {
                            quiet("Only hosts see this. They can't answer, or see the address, the guest list or the updates.")
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    Section { rows(tabs.rows(in: shown), showsStatus: false) }
                        .glassRowBackground()
                } else {
                    quiet("No answers yet.")
                }
            }
        }
        .glassList()
        .disabled(model.isWorking)
    }

    private func rows(_ guests: [Guest], showsStatus: Bool) -> some View {
        ForEach(guests) { guest in
            GuestSheetRow(guest: guest, showsStatus: showsStatus, isHost: model.isHost, onRemove: onRemove, onUndo: onUndo)
        }
    }

    private func quiet(_ words: String) -> some View {
        Text(words)
            .font(.subheadline)
            .foregroundStyle(Palette.muted)
            .listRowBackground(Color.clear)
    }
}

#Preview {
    let model = GuestsModel(event: PreviewData.event(MockEvents.gameNightId))
    GuestsList(model: model, onRemove: { _ in }, onUndo: { _ in })
        .task { await model.load(from: MockEventsRepository(delay: .zero)) }
        .canopyScreen()
}
