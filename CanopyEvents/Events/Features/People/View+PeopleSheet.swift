import SwiftUI

extension View {
    /// The top of a people sheet (the web's `sheetShell`): its title,
    /// small, and Close. For the root of the sheet's stack; a pushed step
    /// (a list's "Add people") gets the system's Back instead. The invite
    /// sheet, a list's sheet and the guests sheet all use it.
    func peopleSheetTitle(_ title: String) -> some View {
        modifier(PeopleSheetTitle(title: title))
    }
}

private struct PeopleSheetTitle: ViewModifier {
    let title: String

    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .close) { dismiss() }
                }
            }
    }
}
