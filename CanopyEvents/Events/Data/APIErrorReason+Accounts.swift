/// The account service's own `reason`s (docs/native-api.md, "Errors").
/// The ones it shares with the events API (`bad_json`, `bad_platform`,
/// `bad_phone`, `bad_instagram`, `bad_origin`, `not_found`, `too_large`,
/// `rate_limited`) are in `APIErrorReason+Events`.
nonisolated extension APIErrorReason {
    static let expired = Self(rawValue: "expired")
    static let badEmail = Self(rawValue: "bad_email")
    static let verifyFirst = Self(rawValue: "verify_first")
    static let namesRequired = Self(rawValue: "names_required")
    static let badVenmo = Self(rawValue: "bad_venmo")
    static let badCashapp = Self(rawValue: "bad_cashapp")
    static let sameEmail = Self(rawValue: "same_email")
    static let unknownPasskey = Self(rawValue: "unknown_passkey")
    static let notVerified = Self(rawValue: "not_verified")
    static let noPhoto = Self(rawValue: "no_photo")
    static let badPhoto = Self(rawValue: "bad_photo")
    static let badUpload = Self(rawValue: "bad_upload")
    static let noPasskeys = Self(rawValue: "no_passkeys")
    /// The token is over: delete it and show sign-in.
    static let signedOut = Self(rawValue: "signed_out")
    static let wrongCode = Self(rawValue: "wrong_code")
    static let reauthRequired = Self(rawValue: "reauth_required")
    static let setupRequired = Self(rawValue: "setup_required")
    static let signedIn = Self(rawValue: "signed_in")
    static let emailHasAccount = Self(rawValue: "email_has_account")
    static let conflict = Self(rawValue: "conflict")
    static let passkeyExists = Self(rawValue: "passkey_exists")
    static let lastPasskey = Self(rawValue: "last_passkey")
    static let emailUnavailable = Self(rawValue: "email_unavailable")
    static let mailFailed = Self(rawValue: "mail_failed")
}
