import SwiftUI

/// The signed-out screen: sign in with a passkey, or by email code, or
/// make a quick account. All mocked: no passkey or email is involved.
struct SignInView: View {
    @Environment(AppSession.self) private var session
    @State private var path: [SignInRoute] = []
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Spacing.xLarge) {
                Spacer()
                CanopyWordmark()
                Spacer()
                VStack(spacing: Spacing.medium) {
                    Button {
                        Task { await signInWithPasskey() }
                    } label: {
                        Label("Sign in with passkey", systemImage: "person.badge.key.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)

                    NavigationLink("Sign in with an email code", value: SignInRoute.emailCode)
                        .buttonStyle(.glass)
                        .controlSize(.large)

                    NavigationLink("New to Canopy? Quick sign-up", value: SignInRoute.quickSignUp)
                        .foregroundStyle(Palette.link)
                        .padding(.top, Spacing.small)
                }
                .disabled(isWorking)
            }
            .padding(Spacing.xLarge)
            .overlay { if isWorking { ProgressView() } }
            .navigationDestination(for: SignInRoute.self) { route in
                switch route {
                case .emailCode: EmailCodeSignInView()
                case .quickSignUp: QuickSignUpView()
                }
            }
            .errorAlert($errorMessage)
            .canopyScreen()
        }
    }

    private func signInWithPasskey() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await session.signInWithPasskey()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignInView()
        .environment(AppSession.mock())
        .preferredColorScheme(.dark)
}
