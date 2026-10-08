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
    init(me: Me) {
        self.init(
            firstName: me.firstName, lastName: me.lastName,
            phone: me.phone ?? "", instagram: me.instagram ?? "",
            venmo: me.venmo ?? "", cashapp: me.cashapp ?? "",
            findable: me.findable ?? true
        )
    }
}
