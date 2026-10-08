/// Signing in, signing up, email verification and your profile: the
/// account service's native API (`account.canopysf.com/api/native/v1`,
/// docs/native-api.md), not the events API's. Each way of signing in ends
/// with a token; `AppSession` turns it into an `EventsRepository`.
///
/// The real one keeps the sign-in's ceremony value between steps, makes
/// and uses passkeys with ASAuthorization, and keeps the token in the
/// Keychain. Today only `MockAccountService` exists (no passkeys, no network).
protocol AccountService: AnyObject, Sendable {
    // MARK: Signing in

    /// `auth/begin`, `auth/passkey/options`, a passkey, `auth/passkey/verify`.
    func signInWithPasskey() async throws -> AuthToken
    /// `auth/begin`, `auth/email/start`: email a 6-digit code (any email
    /// gets one). Again sends a new code.
    func sendSignInCode(to email: String) async throws
    /// `auth/email/verify`: the code proves the email, and says whether
    /// it has an account.
    func checkSignInCode(_ code: String) async throws -> EmailState
    /// For `existing`: `auth/register/existing`, a new passkey on this
    /// phone, `auth/register/verify`. Also proves the account's email.
    func signInWithNewPasskey() async throws -> AuthToken
    /// For `new`: `auth/register/new` with names (and Venmo), a passkey,
    /// `auth/register/verify`. The account is made verified.
    func signUp(firstName: String, lastName: String, venmo: String?) async throws -> AuthToken
    /// `auth/begin`, `auth/quick/start`, a passkey, `auth/register/verify`.
    /// The account starts unverified. `email_has_account` if it has one.
    func quickSignUp(firstName: String, lastName: String, email: String) async throws -> AuthToken

    // MARK: Signed in

    /// `me/verify/start`: email a code that proves your address. Returns
    /// true if there was nothing to prove (already verified).
    func sendVerificationCode(for token: AuthToken) async throws -> Bool
    /// `me/verify/check`: prove the email with that code. Returns you, verified.
    func verifyEmail(code: String, for token: AuthToken) async throws -> Me
    /// `PATCH /me`: save your own profile. Returns you as saved.
    func updateProfile(_ profile: ProfileDraft, for token: AuthToken) async throws -> Me
    /// `POST /signout`. Forget the token whatever happens.
    func signOut(_ token: AuthToken) async
}
