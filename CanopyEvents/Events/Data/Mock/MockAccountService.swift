import Foundation

/// Pretend account service (sign-in, verify, profile) against the shared `MockBackend`. Nothing leaves the
/// device: passkey sign-in always signs in as Maya, and any six-digit
/// code is accepted wherever a code is asked for.
final class MockAccountService: AccountService {
    private let backend: MockBackend

    init(backend: MockBackend) {
        self.backend = backend
    }

    func signInWithPasskey() async throws -> AuthToken {
        await backend.pause()
        return AuthToken(value: MockPeople.maya.id)
    }

    func sendSignInCode(to email: String) async throws {
        await backend.pause()
        guard backend.account(email: email) != nil else { throw Self.noAccount }
    }

    func signIn(email: String, code: String) async throws -> AuthToken {
        await backend.pause()
        try check(code)
        guard var account = backend.account(email: email) else { throw Self.noAccount }
        account.emailVerified = true
        backend.save(account)
        return AuthToken(value: account.id)
    }

    func quickSignUp(firstName: String, lastName: String, email: String) async throws -> AuthToken {
        await backend.pause()
        guard backend.account(email: email) == nil else { throw Self.emailTaken }
        let account = MockPeople.quickUser(
            id: "p-" + UUID().uuidString.lowercased(), firstName: firstName, lastName: lastName, email: email
        )
        backend.save(account)
        return AuthToken(value: account.id)
    }

    func sendVerificationCode(for token: AuthToken) async throws {
        await backend.pause()
    }

    func verifyEmail(code: String, for token: AuthToken) async throws {
        await backend.pause()
        try check(code)
        guard var account = backend.account(id: token.value) else { return }
        account.emailVerified = true
        backend.save(account)
    }

    func updateProfile(_ profile: ProfileDraft, for token: AuthToken) async throws -> Me {
        await backend.pause()
        guard var account = backend.account(id: token.value) else { throw Self.noAccount }
        account.firstName = profile.firstName.trimmingCharacters(in: .whitespaces)
        account.lastName = profile.lastName.trimmingCharacters(in: .whitespaces)
        account.shortName = PersonName.short(firstName: account.firstName, lastName: account.lastName)
        account.phone = profile.phone.isEmpty ? nil : profile.phone
        account.instagram = profile.instagram.isEmpty ? nil : profile.instagram
        account.venmo = profile.venmo.isEmpty ? nil : profile.venmo
        account.cashapp = profile.cashapp.isEmpty ? nil : profile.cashapp
        account.findable = profile.findable
        backend.save(account)
        return account
    }

    func signOut(_ token: AuthToken) async {
        await backend.pause()
    }

    // MARK: Helpers

    private func check(_ code: String) throws {
        guard code.count == 6, code.allSatisfy(\.isNumber) else { throw Self.badCode }
    }

    private static let noAccount = APIError(message: "No Canopy account uses that email. Try quick sign-up.", reason: "no_account")
    private static let emailTaken = APIError(message: "This email has an account. Sign in instead.", reason: "email_taken")
    private static let badCode = APIError(message: "That code isn't right. (Mock: any six digits work.)", reason: "bad_code")
}
