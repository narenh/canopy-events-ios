import Foundation

/// Pretend account service (sign-in, verify, profile) against the shared
/// `MockBackend`. Nothing leaves the device and no passkey is made:
/// passkey sign-in is always Maya, and any six digits pass as a code.
final class MockAccountService: AccountService {
    private let backend: MockBackend
    /// The email a sign-in code went to, and whether the code proved it.
    private var pendingEmail: String?
    private var emailProven = false

    init(backend: MockBackend) {
        self.backend = backend
    }

    func signInWithPasskey() async throws -> AuthToken {
        await backend.pause()
        return AuthToken(value: MockPeople.maya.id)
    }

    func sendSignInCode(to email: String) async throws {
        await backend.pause()
        guard email.contains("@") else { throw APIError(message: "That isn't an email.", reason: .badEmail) }
        pendingEmail = email.lowercased()
        emailProven = false
    }

    func checkSignInCode(_ code: String) async throws -> EmailState {
        await backend.pause()
        guard let email = pendingEmail else { throw Self.expired }
        try check(code)
        emailProven = true
        guard let account = backend.account(email: email) else {
            return EmailState(verified: true, state: .new, email: email)
        }
        return EmailState(verified: true, state: .existing, email: email, firstName: account.firstName,
                          hasPasskey: true, unverified: !account.emailVerified)
    }

    func signInWithNewPasskey() async throws -> AuthToken {
        await backend.pause()
        guard emailProven, let email = pendingEmail, var account = backend.account(email: email) else { throw Self.verifyFirst }
        account.emailVerified = true
        backend.save(account)
        pendingEmail = nil
        return AuthToken(value: account.id)
    }

    func signUp(firstName: String, lastName: String, venmo: String?) async throws -> AuthToken {
        await backend.pause()
        guard emailProven, let email = pendingEmail else { throw Self.verifyFirst }
        try checkNames(firstName, lastName)
        var account = MockPeople.quickUser(id: UUID().uuidString.lowercased(), firstName: firstName, lastName: lastName, email: email)
        account.emailVerified = true
        account.venmo = venmo
        backend.save(account)
        pendingEmail = nil
        return AuthToken(value: account.id)
    }

    func quickSignUp(firstName: String, lastName: String, email: String) async throws -> AuthToken {
        await backend.pause()
        try checkNames(firstName, lastName)
        guard backend.account(email: email) == nil else { throw APIError.emailHasAccount(email) }
        let account = MockPeople.quickUser(
            id: UUID().uuidString.lowercased(), firstName: firstName, lastName: lastName, email: email.lowercased()
        )
        backend.save(account)
        return AuthToken(value: account.id)
    }

    func sendVerificationCode(for token: AuthToken) async throws -> Bool {
        await backend.pause()
        return backend.account(id: token.value)?.emailVerified ?? false
    }

    func verifyEmail(code: String, for token: AuthToken) async throws -> Me {
        await backend.pause()
        try check(code)
        guard var account = backend.account(id: token.value) else { throw Self.signedOut }
        account.emailVerified = true
        backend.save(account)
        return account
    }

    func updateProfile(_ profile: ProfileDraft, for token: AuthToken) async throws -> Me {
        await backend.pause()
        guard var account = backend.account(id: token.value) else { throw Self.signedOut }
        try checkNames(profile.firstName, profile.lastName)
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
        guard code.count == 6, code.allSatisfy(\.isNumber) else { throw APIError.wrongCode }
    }

    private func checkNames(_ firstName: String, _ lastName: String) throws {
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
              !lastName.trimmingCharacters(in: .whitespaces).isEmpty
        else { throw APIError(message: "First and last name, please.", reason: .namesRequired) }
    }

    private static let expired = APIError(message: "That code ran out. Send a new one.", reason: .expired)
    private static let verifyFirst = APIError(message: "Prove your email with a code first.", reason: .verifyFirst)
    private static let signedOut = APIError(message: "You've been signed out.", reason: .signedOut)
}
