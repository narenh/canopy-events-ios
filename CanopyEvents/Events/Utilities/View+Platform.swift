import SwiftUI

/// The few iPhone/iPad-only modifiers the app uses, wrapped so the target
/// still builds for macOS (it's in the project's supported platforms).
/// On macOS each one does nothing.
extension View {
    /// A small title in the bar, for sheets and forms.
    func inlineNavigationTitle() -> some View {
        #if os(macOS)
        self
        #else
        navigationBarTitleDisplayMode(.inline)
        #endif
    }

    /// An email field: email keyboard, no capitals, no autocorrect.
    func emailField() -> some View {
        #if os(macOS)
        textContentType(.emailAddress)
        #else
        self
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #endif
    }

    /// A one-time-code field: number pad and code autofill.
    func oneTimeCodeField() -> some View {
        #if os(macOS)
        self
        #else
        self
            .textContentType(.oneTimeCode)
            .keyboardType(.numberPad)
        #endif
    }
}
