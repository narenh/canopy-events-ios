import SwiftUI

extension View {
    /// "Duplicate": while `draft` is set, the new-event editor filled in
    /// from it; once the copy is made, the copy pushed onto this stack,
    /// with Lists… showing when its original had your own lists on it (as
    /// the web's `?lists=1`). Adding one there still asks first.
    func duplicating(_ draft: Binding<DuplicateDraft?>) -> some View {
        modifier(DuplicatingModifier(draft: draft))
    }
}

private struct DuplicatingModifier: ViewModifier {
    @Binding var draft: DuplicateDraft?
    @State private var copy: MadeCopy?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isEditing) {
                if let draft {
                    EventEditorView(duplicating: draft) { event in
                        copy = MadeCopy(id: event.id, showsLists: !draft.lists.isEmpty)
                    }
                }
            }
            .navigationDestination(item: $copy) { copy in
                EventDetailView(eventId: copy.id, showsLists: copy.showsLists)
                    .verifyEmailBanner()
            }
    }

    private var isEditing: Binding<Bool> {
        Binding(get: { draft != nil }, set: { if !$0 { draft = nil } })
    }
}

/// A copy just made, to open.
private struct MadeCopy: Hashable {
    let id: Event.ID
    let showsLists: Bool
}
