import Foundation

/// The parts of your own profile you can edit from the app. Your profile
/// lives in the account service; this is what gets sent to it.
nonisolated struct ProfileDraft: Hashable {
    var firstName: String
    var lastName: String
    var phone: String
    var instagram: String
    var venmo: String
    var cashapp: String
    /// "Let people who know your phone or Instagram find you."
    var findable: Bool

    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

extension ProfileDraft {
    init(profile: AccountProfile) {
        self.init(
            firstName: profile.firstName, lastName: profile.lastName,
            phone: profile.phone ?? "", instagram: profile.instagram ?? "",
            venmo: profile.venmo ?? "", cashapp: profile.cashapp ?? "",
            findable: profile.findable
        )
    }
}
