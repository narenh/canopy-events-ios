import Foundation
import Observation

/// Who is signed in, and the repository that talks to the events API as
/// them. Screens read it with `@Environment(AppSession.self)`.
///
/// Signing in (and your profile) goes through an `AccountService`, which hands back a token;
/// `makeRepository` turns that token into an `EventsRepository`. Today
/// both are mocks sharing one `MockBackend` (see `AppSession.mock()`).
/// Later: `AppSession(accounts: AccountServiceClient(), makeRepository: { APIEventsRepository(token: $0) })`.
@Observable
final class AppSession {
    /// You and your verify link; nil while signed out.
    private(set) var account: MeEnvelope?
    /// The signed-in person's repository.
    private(set) var repository: any EventsRepository
    private var token: AuthToken?
    /// Goes up when the data changed behind the screens' backs (an answer
    /// from a notification, the app coming back): lists reload on it with
    /// `.task(id: session.dataVersion)`.
    private(set) var dataVersion = 0
    @ObservationIgnored private let accounts: any AccountService
    @ObservationIgnored private let makeRepository: (AuthToken) -> any EventsRepository

    init(
        accounts: any AccountService,
        makeRepository: @escaping (AuthToken) -> any EventsRepository,
        repository: any EventsRepository = MockEventsRepository()
    ) {
        self.accounts = accounts
        self.makeRepository = makeRepository
        self.repository = repository
    }

    var me: Me? { account?.person }
    /// You as the Canopy Account service has you, with your own contact
    /// details (the events API has none): for the Profile and the verify
    /// sheet. Loaded at sign-in; nil if it couldn't be.
    private(set) var profile: AccountProfile?
    var isSignedIn: Bool { account != nil }
    var needsVerification: Bool { me.map { !$0.emailVerified } ?? false }
    /// Once you've hosted anything, the app shows its hosting UI for good.
    var isHost: Bool { account?.hasHosted ?? false }

    // MARK: Signing in

    func signInWithPasskey() async throws {
        try await signIn(with: try await accounts.signInWithPasskey())
    }

    func sendSignInCode(to email: String) async throws {
        try await accounts.sendSignInCode(to: email)
    }

    /// Checks the emailed code: the email is proven, and the answer says
    /// whether it has an account (then `signInWithNewPasskey()`) or not
    /// (then `signUp(firstName:lastName:venmo:)`).
    func checkSignInCode(_ code: String) async throws -> EmailState {
        try await accounts.checkSignInCode(code)
    }

    /// After a proven email with an account: a passkey for this phone.
    func signInWithNewPasskey() async throws {
        try await signIn(with: try await accounts.signInWithNewPasskey())
    }

    /// After a proven email with no account: a new, verified one.
    func signUp(firstName: String, lastName: String, venmo: String?) async throws {
        try await signIn(with: try await accounts.signUp(firstName: firstName, lastName: lastName, venmo: venmo))
    }

    func quickSignUp(firstName: String, lastName: String, email: String) async throws {
        try await signIn(with: try await accounts.quickSignUp(firstName: firstName, lastName: lastName, email: email))
    }

    /// Makes the repository for `token` and loads you through it.
    func signIn(with token: AuthToken) async throws {
        let repository = makeRepository(token)
        account = try await repository.me()
        self.repository = repository
        self.token = token
        profile = try? await accounts.profile(for: token)
    }

    func signOut() async {
        if let token { await accounts.signOut(token) }
        account = nil
        profile = nil
        token = nil
    }

    /// Tells the screens to reload.
    func dataChanged() {
        dataVersion += 1
    }

    /// Reloads you, e.g. after creating your first event (which makes you a host).
    func refresh() async throws {
        account = try await repository.me()
    }

    // MARK: Verifying your email

    func sendVerificationCode() async throws {
        guard let token else { return }
        let alreadyVerified = try await accounts.sendVerificationCode(for: token)
        if alreadyVerified { try await refresh() }
    }

    func verifyEmail(code: String) async throws {
        guard let token else { return }
        profile = try await accounts.verifyEmail(code: code, for: token)
        account = try await repository.me()
    }

    // MARK: Your profile

    func updateProfile(_ profile: ProfileDraft) async throws {
        guard let token else { return }
        self.profile = try await accounts.updateProfile(profile, for: token)
        account = try await repository.me()
    }
}
