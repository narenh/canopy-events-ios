import SwiftUI

/// The keyboards the editor's fields ask for, with autocorrection and
/// capitals off for addresses and numbers. On the Mac and Vision (no
/// such keyboards) it does nothing.
enum KeyboardKind {
    case url
    case phone
}

extension View {
    func keyboardKind(_ kind: KeyboardKind) -> some View {
        #if os(iOS)
        self
            .keyboardType(kind == .url ? .URL : .phonePad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #else
        self.autocorrectionDisabled()
        #endif
    }
}
