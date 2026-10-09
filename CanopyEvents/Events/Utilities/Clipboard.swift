#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Copying text, the same call on every platform the app builds for.
enum Clipboard {
    static func copy(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}
