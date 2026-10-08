import SwiftUI

/// Quick sign-up for people new to Canopy: first name, last name, email,
/// then a passkey. The account works right away but stays unverified
/// (with the banner) until the email is proven. Mock: no passkey is made.
struct QuickSignUpView: View {
    @Environment(AppSession.self) private var session
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var isWorking = false
    @State private var errorMessage: String?

    private var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
            && email.contains("@")
    }

    var body: some View {
        Form {
            Section {
                TextField("First name", text: $firstName)
                    .textContentType(.givenName)
                TextField("Last name", text: $lastName)
                    .textContentType(.familyName)
                TextField("Email", text: $email)
                    .emailField()
            } footer: {
                Text("Hosts and guests see your name as \(previewName). Your email is never shown to anyone.")
            }
            .glassRowBackground()
            Section {
                Button {
                    Task { await signUp() }
                } label: {
                    Label("Continue with passkey", systemImage: "person.badge.key.fill")
                }
                .disabled(!isValid || isWorking)
            }
            .glassRowBackground()
        }
        .navigationTitle("Quick sign-up")
        .errorAlert($errorMessage)
        .canopyScreen()
    }

    private var previewName: String {
        firstName.isEmpty ? "\"Ana L\"" : "\"\(PersonName.short(firstName: firstName, lastName: lastName))\""
    }

    private func signUp() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await session.quickSignUp(firstName: firstName, lastName: lastName, email: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { QuickSignUpView() }
        .environment(AppSession.mock())
        .preferredColorScheme(.dark)
}
