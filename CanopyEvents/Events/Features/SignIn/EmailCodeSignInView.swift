import SwiftUI

/// Signing in with a code sent to your email: enter the email, then the
/// code. Signing in this way also verifies a quick account.
/// Mock: maya@example.com or sam@example.com, and any six digits.
struct EmailCodeSignInView: View {
    @Environment(AppSession.self) private var session
    @State private var email = ""
    @State private var code = ""
    @State private var codeSent = false
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .emailField()
                    .disabled(codeSent)
            } footer: {
                Text("Mock accounts: maya@example.com (verified), sam@example.com (quick).")
            }
            if codeSent {
                Section {
                    CodeField(code: $code)
                } header: {
                    Text("Code")
                } footer: {
                    Text("Mock: no email is sent. Any six digits work.")
                }
            }
            Section {
                Button(codeSent ? "Sign in" : "Send code") {
                    Task { codeSent ? await signIn() : await sendCode() }
                }
                .disabled(isWorking || (codeSent ? code.count != 6 : !email.contains("@")))
            }
        }
        .navigationTitle("Sign in with a code")
        .errorAlert($errorMessage)
        .canopyScreen()
    }

    private func sendCode() async {
        await run { try await session.sendSignInCode(to: email) }
        codeSent = errorMessage == nil
    }

    private func signIn() async {
        await run { try await session.signIn(email: email, code: code) }
    }

    private func run(_ work: () async throws -> Void) async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await work()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { EmailCodeSignInView() }
        .environment(AppSession.mock())
        .preferredColorScheme(.dark)
}
