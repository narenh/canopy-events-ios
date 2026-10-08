import SwiftUI

/// Proving your email with a code, which turns a quick account into a
/// full one and clears the banner. Mock: any six digits work.
struct VerifyEmailSheet: View {
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CodeField(code: $code)
                } header: {
                    Text("Enter the code we sent to \(session.me?.email ?? "your email")")
                } footer: {
                    Text("Mock: no email is sent. Any six digits work.")
                }
                Section {
                    Button("Send a new code") { Task { await sendCode() } }
                        .disabled(isWorking)
                }
            }
            .navigationTitle("Verify your email")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Verify", role: .confirm) { Task { await verify() } }
                        .disabled(code.count != 6 || isWorking)
                }
            }
            .task { await sendCode() }
            .errorAlert($errorMessage)
            .canopyScreen()
        }
        .presentationDetents([.medium])
    }

    private func sendCode() async {
        do {
            try await session.sendVerificationCode()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func verify() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await session.verifyEmail(code: code)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    VerifyEmailSheet()
        .mockEnvironment(signedInAs: MockPeople.sam)
}
