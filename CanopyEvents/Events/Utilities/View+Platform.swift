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

    /// A spinning wheel of a date or time picker (the Mac's own compact
    /// field there, which has no wheel).
    func wheelDatePickerStyle() -> some View {
        #if os(macOS)
        datePickerStyle(.field)
        #else
        datePickerStyle(.wheel)
        #endif
    }

    /// Scrolling puts the keyboard away (there's no keyboard to hide on
    /// visionOS or the Mac).
    func dismissesKeyboardOnScroll() -> some View {
        #if os(iOS)
        scrollDismissesKeyboard(.interactively)
        #else
        self
        #endif
    }
}
