import SwiftUI

/// A six-digit one-time code field, with the system's code autofill.
/// Used for verifying your email and for signing in by email code.
struct CodeField: View {
    @Binding var code: String

    var body: some View {
        TextField("123456", text: $code)
            .textContentType(.oneTimeCode)
            .keyboardType(.numberPad)
            .font(.title2.monospacedDigit())
            .onChange(of: code) { _, newValue in
                code = String(newValue.filter(\.isNumber).prefix(6))
            }
    }
}

#Preview {
    @Previewable @State var code = ""
    Form { CodeField(code: $code) }
        .preferredColorScheme(.dark)
}
