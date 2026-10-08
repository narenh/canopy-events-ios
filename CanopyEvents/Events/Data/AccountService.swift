/// Signing in, quick sign-up, email verification and your profile: the
/// account service's job (`account.canopysf.com`), not the events API's. Each sign-in method returns a
/// token; `AppSession` turns the token into an `EventsRepository`.
///
/// Tonight only `MockAccountService` exists (no passkeys, no network). The
/// real one will use ASAuthorization passkeys against
/// `account.canopysf.com`, once its native sign-in is built.
protocol AccountService: AnyObject, Sendable {
    /// Sign in with a passkey on this device.
    func signInWithPasskey() async throws -> AuthToken
    /// Email a one-time sign-in code.
    func sendSignInCode(to email: String) async throws
    /// Sign in with an emailed code. For an unverified account, this also
    /// verifies it.
    func signIn(email: String, code: String) async throws -> AuthToken
    /// Quick sign-up: name and email, then a passkey. The account starts
    /// unverified. Fails with `email_taken` if the email has an account.
    func quickSignUp(firstName: String, lastName: String, email: String) async throws -> AuthToken
    /// Email a code that proves the signed-in person's address.
    func sendVerificationCode(for token: AuthToken) async throws
    /// Prove the email with that code; the account becomes verified.
    func verifyEmail(code: String, for token: AuthToken) async throws
    /// Save your own profile. Returns you as saved.
    func updateProfile(_ profile: ProfileDraft, for token: AuthToken) async throws -> Me
    func signOut(_ token: AuthToken) async
}
